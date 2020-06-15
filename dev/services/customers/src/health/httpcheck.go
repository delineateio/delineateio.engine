package health

import (
	"net/url"
	"time"

	h "github.com/InVisionApp/go-health/v2"
	"github.com/InVisionApp/go-health/v2/checkers"
	l "github.com/delineateio/core/logging"
)

// AddHTTPCheck adds a check to a specific HTTP end point
func (m *Monitor) AddHTTPCheck(name string, interval time.Duration, fatal bool, rawurl string) {

	// Create a checker
	var check *checkers.HTTP
	url, err := url.Parse(rawurl)
	if err != nil {
		l.Error("healthcheck.http.url.error", err)
	}

	check, err = checkers.NewHTTP(&checkers.HTTPConfig{
		URL: url,
	})
	if err != nil {
		l.Error("healthcheck.http.add.error", err)
	}

	var config = h.Config{
		Name:     name,
		Interval: interval,
		Fatal:    fatal,
		Checker:  check,
	}

	m.AddCheck(name, interval, fatal, config)
}
