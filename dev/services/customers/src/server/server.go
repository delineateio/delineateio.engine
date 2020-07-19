package server

import (
	"os"
	"strings"

	c "github.com/delineateio/core/config"
	l "github.com/delineateio/core/logging"
	r "github.com/delineateio/core/repository"
	"github.com/fsnotify/fsnotify"
	"github.com/fvbock/endless"
	"github.com/gin-gonic/gin"
)

// NewServer creates a new server
func NewServer(routes func() []gin.RouteInfo) *Server {
	// Gets env
	env := os.Getenv("ENV")
	location := os.Getenv("LOCATION")

	server := &Server{
		Env:       env,
		Location:  location,
		GetRoutes: routes,
	}
	server.Configure()
	server.setMode()
	server.TimeOuts = readTimeOuts()
	return server
}

// Server represents the encapulsation of a service
// Don't rely on server defaults as this could significant impact performance]
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
	c.NewConfigurator(s.Env, s.Location).LoadWithCallback(s.reload)

	// Sets up the logger - this is abastracted into a separate func so
	// that it can be called as part of the reload
	s.setLogger()

	// Logs the config level
	l.Info("config.initialised", "the env config has been set to '"+s.Env+"'")
}

func (s *Server) setLogger() {
	// Gets the config
	level := c.GetString("logging.level", "warn")

	// Reloads
	l.NewLogger(level).Load()
}

func (s *Server) reload(in fsnotify.Event) {
	// Sets up the logger
	s.setLogger()

	// Sets the timeouts
	setTimeOuts()
}

func (s *Server) setMode() {
	mode := strings.ToLower(c.GetString("server.mode", "release"))
	if mode != gin.ReleaseMode && mode != gin.DebugMode {
		l.Warn("server.mode", "Configuration incorrect, defaulted to 'release'")
		mode = gin.ReleaseMode
	}
	s.Mode = mode
}

// CreateRouter returns the router that will be returned
func (s *Server) CreateRouter() *gin.Engine {
	// Misconfiguration can lead to the service not starting
	// The wrapper func defaults to 'release' if that is the case
	gin.SetMode(s.Mode)
	router := gin.Default()

	// Adds healthz at the route
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

// Start the server and ensure it's configured
func (s *Server) Start() {
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

	// Starts the server
	port := c.GetString("server.port", "1102")
	_ = endless.ListenAndServe(":"+port, s.Router)

	if err != nil {
		l.Warn("server.shutdown", "server has shutdown.  Goodbye!")
	}
}
