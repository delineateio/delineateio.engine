package main

import (
	"os"

	s "github.com/delineateio/core/server"
	"github.com/gin-gonic/gin"
)

func main() {
	server := s.NewServer(getRoutes, NewCustomerRepository())
	server.Env = os.Getenv("ENV")
	server.Location = os.Getenv("LOCATION")
	server.Configure()
	server.Start()
}

func getRoutes() []gin.RouteInfo {
	return []gin.RouteInfo{
		{
			Method: "GET",
			Path:   "/",
			HandlerFunc: func(ctx *gin.Context) {
				s.Dispatch(ctx, s.Healthz)
			},
		},
		{
			Method: "GET",
			Path:   "/healthz",
			HandlerFunc: func(ctx *gin.Context) {
				s.Dispatch(ctx, s.Healthz)
			},
		},
		{
			Method: "POST",
			Path:   "/customer",
			HandlerFunc: func(ctx *gin.Context) {
				s.Dispatch(ctx, addCustomer)
			},
		},
	}
}
