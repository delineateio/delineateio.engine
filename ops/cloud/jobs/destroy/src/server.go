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

// PubSubHandler is an http handler that invokes the destroyer from a pubsub
// request. Unlike an HTTP request, the pubsub endpoint always returns a success
// unless the pubsub message is malformed.
func (s *Server) PubSubHandler() http.HandlerFunc {

	return func(w http.ResponseWriter, r *http.Request) {
		var msg pubsubMessage
		if err := json.NewDecoder(r.Body).Decode(&msg); err != nil {
			err = fmt.Errorf("failed to decode pubsub message: %w", err)
			s.handleError(w, err, http.StatusBadRequest)
			return
		}

		if len(msg.Message.Data) == 0 {
			err := fmt.Errorf("missing data in pubsub payload")
			s.handleError(w, err, http.StatusBadRequest)
			return
		}

		// Start a goroutine to delete the infrastructue
		body := ioutil.NopCloser(bytes.NewReader(msg.Message.Data))
		go func() {
			if _, err := s.destroy(body); err != nil {
				log.Printf("error async: %s", err.Error())
			}
		}()

		w.WriteHeader(http.StatusAccepted)
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

		w.WriteHeader(status)
		w.Header().Set(contentTypeHeader, contentTypeJSON)
	}
}

// destroy reads the given body as JSON and starts a destroy instance.
func (s *Server) destroy(r io.ReadCloser) (int, error) {

	var payload payload

	if err := json.NewDecoder(r).Decode(&payload); err != nil {
		fmt.Println(err)
		return http.StatusBadRequest, err
	}

	fmt.Println(payload)
	err := s.destroyer.Destroy(payload)
	if err != nil {
		fmt.Println(err)
		return http.StatusInternalServerError, err
	}

	return http.StatusOK, nil
}

// handleError returns a JSON-formatted error message
func (s *Server) handleError(w http.ResponseWriter, err error, status int) {

	log.Printf("error %d: %s", status, err.Error())

	b, err := json.Marshal(&errorResp{Error: err.Error()})
	if err != nil {
		err = fmt.Errorf("failed to marshal JSON errors: %w", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	w.WriteHeader(status)
	w.Header().Set(contentTypeHeader, contentTypeJSON)
	fmt.Fprint(w, string(b))
}

type payload struct {
	Env        string   `json:"env"`
	RepoURL    string   `json:"repo_url"`
	RepoRoot   string   `json:"repo_root"`
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
