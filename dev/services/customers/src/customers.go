package main

import (
	"net/http"

	l "github.com/delineateio/core/logging"
	s "github.com/delineateio/core/server"
	"github.com/jinzhu/gorm"
	"github.com/mitchellh/mapstructure"
	_ "github.com/swaggo/swag/example/celler/httputil"
)

// Customer represents a customer within this specific domain
type Customer struct {
	gorm.Model
	Forename string `json:"forename" binding:"required"`
	Surname  string `json:"surname" binding:"required"`
}

// PingExample godoc
// @Summary ping example
// @Description do ping
// @Tags example
// @Accept json
// @Produce json
// @Success 200 {string} string "pong"
// @Failure 400 {string} string "ok"
// @Failure 404 {string} string "ok"
// @Failure 500 {string} string "ok"
// @Router /examples/ping [get]
func addCustomer(request *s.Request, response *s.Response) {
	customer := Customer{}
	err := mapstructure.Decode(request.Body, &customer)
	if err != nil {
		l.Error("", err)
		response.Code = http.StatusBadRequest
	}

	err = NewCustomerRepository().CreateCustomer(&customer)
	if err != nil {
		response.Code = http.StatusServiceUnavailable
		return
	}

	response.Code = http.StatusOK
}
