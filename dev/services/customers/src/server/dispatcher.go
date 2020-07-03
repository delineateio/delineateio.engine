package server

import (
	"net/http"

	l "github.com/delineateio/core/logging"
	"github.com/gin-gonic/gin"
)

// Request generically represents inputs to the service
type Request struct {
	Body map[string]interface{}
}

// Response generically represents outputs from the service
type Response struct {
	Code int         `json:"code"`
	Body interface{} `json:"body,omitempty"`
}

// Command performs the required action for the service
type command func(request *Request, response *Response)

// Dispatch initiates and handles the request and response
func Dispatch(ctx *gin.Context, command command) {
	request := Request{
		Body: make(map[string]interface{}),
	}

	err := ctx.ShouldBind(&request.Body)
	if err != nil {
		l.Error("request.bind.error", err)
		ctx.JSON(http.StatusBadRequest, nil)
		return
	}

	var response Response
	command(&request, &response)

	// Adds the headers
	ctx.Header("Content-Type", "application/json")

	// Only writes the body
	if response.Body == nil {
		ctx.Writer.WriteHeader(response.Code)
	} else {
		ctx.JSON(response.Code, response.Body)
	}
}
