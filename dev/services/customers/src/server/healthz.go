package server

import (
	"net/http"

	h "github.com/delineateio/core/health"
	l "github.com/delineateio/core/logging"
)

// Healthz is the health check - the name is inspired by
// a forgotten source that this is the naming conventions at Google
func Healthz(request *Request, response *Response) {
	status := h.NewMonitor().GetStatus()
	l.Debug("healthcheck.ping", "Health check was called")

	// If there are no checks configured then the service is good
	// Otherwise the status will be taken from the status check
	if !status.IsMonitoring {
		response.Code = http.StatusOK
		return
	}

	if status.Failed {
		response.Code = http.StatusServiceUnavailable
	} else {
		response.Code = http.StatusOK
	}
}
