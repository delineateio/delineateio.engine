package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/DATA-DOG/go-sqlmock"
	s "github.com/delineateio/core/server"
	"github.com/jinzhu/gorm"
	"github.com/stretchr/testify/assert"
)

// TestCustomerRoute for testing the simple healthz
func TestHTTPCustomerRouteMockDB(t *testing.T) {

	r := NewCustomerRepository()

	// Creates the mock for testing purposes
	db, mock, err := sqlmock.New()
	assert.NoError(t, err) // Asserts there is no error
	mock.ExpectClose()
	r.core.SetDBFunc = func() (*gorm.DB, error) {
		return gorm.Open("postgres", db) // open gorm db
	}

	// Configures the server
	server := s.NewServer(getRoutes, r)
	server.Env = "http"
	server.Location = "../tests"
	server.Configure()
	router := server.CreateRouter()

	// reader with ths json
	reader := strings.NewReader(`{"forename":"jonathan","surname":"fenwick"}`)

	// Get the results
	recorder := httptest.NewRecorder()
	req, _ := http.NewRequest("POST", "/customer", reader)
	req.Header.Set("Content-Type", "application/json")
	router.ServeHTTP(recorder, req)

	// Assert as required
	assert.Equal(t, http.StatusOK, recorder.Code)
}
