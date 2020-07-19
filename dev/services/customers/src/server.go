package main

import (
	s "github.com/delineateio/core/server"
	"github.com/gin-gonic/gin"

	_ "github.com/swaggo/gin-swagger/example/basic/docs"
)

func main() {
	server := s.NewServer(getRoutes)
	server.Repository = NewCustomerRepository()
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
