package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
)

const (
	contentTypeHeader = "Content-Type"
	contentTypeJSON   = "application/json"
)

// Server is a cleaning server.
type Server struct {
	destroyer *Destroyer
}

// NewServer creates a new server for handler functions.
func NewServer(destroyer *Destroyer) (*Server, error) {
	if destroyer == nil {
		return nil, fmt.Errorf("missing destroyer")
	}

	return &Server{
		destroyer: destroyer,
	}, nil
}

// PubSubHandler is an http handler that invokes the cleaner from a pubsub
// request. Unlike an HTTP request, the pubsub endpoint always returns a success
// unless the pubsub message is malformed.
func (s *Server) PubSubHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var m pubsubMessage
		if err := json.NewDecoder(r.Body).Decode(&m); err != nil {
			err = fmt.Errorf("failed to decode pubsub message: %w", err)
			s.handleError(w, err, 400)
			return
		}

		if len(m.Message.Data) == 0 {
			err := fmt.Errorf("missing data in pubsub payload")
			s.handleError(w, err, 400)
			return
		}

		// Start a goroutine to delete the infrastructue
		body := ioutil.NopCloser(bytes.NewReader(m.Message.Data))
		go func() {
			if _, err := s.destroy(body); err != nil {
				log.Printf("error async: %s", err.Error())
			}
		}()

		w.WriteHeader(204)
	}
}

// HTTPHandler is an http handler that invokes the destroyer with the given
// parameters.
func (s *Server) HTTPHandler() http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		status, err := s.destroy(r.Body)
		if err != nil {
			s.handleError(w, err, status)
			return
		}

		w.WriteHeader(200)
		w.Header().Set(contentTypeHeader, contentTypeJSON)
	}
}

// destroy reads the given body as JSON and starts a destroy instance.
func (s *Server) destroy(r io.ReadCloser) (int, error) {

	var p Payload
	if err := json.NewDecoder(r).Decode(&p); err != nil {
		return 500, err
	}

	components := p.Components

	err := s.destroyer.Destroy(components)

	if err != nil {
		return 400, err
	}

	return 200, nil
}

// handleError returns a JSON-formatted error message
func (s *Server) handleError(w http.ResponseWriter, err error, status int) {

	log.Printf("error %d: %s", status, err.Error())

	b, err := json.Marshal(&errorResp{Error: err.Error()})
	if err != nil {
		err = fmt.Errorf("failed to marshal JSON errors: %w", err)
		http.Error(w, err.Error(), 500)
		return
	}

	w.WriteHeader(status)
	w.Header().Set(contentTypeHeader, contentTypeJSON)
	fmt.Fprint(w, string(b))
}

// Payload is the expected incoming payload format.
type Payload struct {
	// Repo is the name of the repo in the format gcr.io/foo/bar
	Components []string `json:"components"`
}

type pubsubMessage struct {
	Message struct {
		Data []byte `json:"data"`
		ID   string `json:"message_id"`
	} `json:"message"`
	Subscription string `json:"subscription"`
}

type errorResp struct {
	Error string `json:"error"`
}
