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
			Method: "POST",
			Path:   "/customer",
			HandlerFunc: func(ctx *gin.Context) {
				s.Dispatch(ctx, addCustomer)
			},
		},
	}
}
