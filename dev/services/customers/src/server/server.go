package server

import (
	"strings"

	c "github.com/delineateio/core/config"
	l "github.com/delineateio/core/logging"
	r "github.com/delineateio/core/repository"
	"github.com/fsnotify/fsnotify"
	"github.com/fvbock/endless"
	"github.com/gin-gonic/gin"
)

// NewServer creates a new server
func NewServer(getRoutes func() []gin.RouteInfo, repository r.IRepository) *Server {

	return &Server{
		Repository: repository,
		Mode:       getMode(),
		GetRoutes:  getRoutes,
		TimeOuts:   readTimeOuts(),
	}
}

// Server represents the encapulsation of a service
// Don't rely on server defaults as this could signficantly impact performance]
// https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/
type Server struct {
	Env          string
	Location     string
	Configurator c.Configurator
	Repository   r.IRepository
	Mode         string
	Router       *gin.Engine
	GetRoutes    func() []gin.RouteInfo
	TimeOuts     TimeOuts
}

// Configure returns the router that will be returned
func (s *Server) Configure() {

	// Before do anything need to load the configuration
	c.NewConfigurator(s.Env, s.Location).LoadWithCallback(reload)

	// Sets up the logger - this is abastracted into a seperate func so
	// that it can be called as part of the reload
	setLogger()
}

func setLogger() {

	// Gets the config
	level := c.GetString("logging.level", "warn")

	// Reloads
	l.NewLogger(level).Load()
}

func reload(in fsnotify.Event) {

	//sets up the logger
	setLogger()

	// sets the timeouts
	setTimeOuts()
}

func getMode() string {

	mode := strings.ToLower(c.GetString("server.mode", "release"))
	if mode != gin.ReleaseMode && mode != gin.DebugMode {
		l.Warn("server.mode", "Configuration incorrect, defaulted to 'release'")
		return gin.ReleaseMode
	}

	return mode
}

// CreateRouter returns the router that will be returned
func (s *Server) CreateRouter() *gin.Engine {

	// Misconfiguration can lead to the service not starting
	// The wrapper func defaults to 'release' if that is the case
	gin.SetMode(s.Mode)
	router := gin.Default()

	// Adds healthz at the route
	s.addHealthz(router)

	l.Info("server.router.create", "created the GIN router")

	// Adds the routes
	if s.GetRoutes != nil {

		for _, route := range s.GetRoutes() {
			router.Handle(route.Method, route.Path, route.HandlerFunc)
		}

		l.Info("server.routes.add", "routes have been added")
	}

	return router
}

func (s *Server) addHealthz(router *gin.Engine) {

	router.GET("/healthz", func(ctx *gin.Context) {
		Dispatch(ctx, Healthz)
	})
}

// Start the server and ensure it's configured
func (s *Server) Start() {

	// s.Repository.Migrate()
	// Migrates the database
	err := s.Repository.Migrate()
	if err != nil {
		l.Warn("server.start", "there could be issues as the server did not start cleanly")
	}

	// Create router
	s.Router = s.CreateRouter()

	// Configures the timeouts for the server
	updateTimeOuts(s.TimeOuts)
	l.Info("server.timeouts", "server timeout configuration completed")

	//Starts the server
	port := c.GetString("server.port", "8080")
	err = endless.ListenAndServe(":"+port, s.Router)

	if err != nil {
		l.Warn("server.shutdown", "server has shutdown.  Goodbye!")
	}
}
