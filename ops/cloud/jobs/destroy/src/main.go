package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"time"

	gcrauthn "github.com/google/go-containerregistry/pkg/authn"
	gcrgoogle "github.com/google/go-containerregistry/pkg/v1/google"
)

func main() {

	// Disable timestamps in go logs because stackdriver has them already.
	log.SetFlags(log.Flags() &^ (log.Ldate | log.Ltime))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	addr := "0.0.0.0:" + port

	var auther gcrauthn.Authenticator
	var err error
	auther, err = gcrgoogle.NewEnvAuthenticator()
	if err != nil {
		log.Fatalf("failed to setup auther: %s", err)
	}

	destroyer, err := NewDestroyer(auther)
	if err != nil {
		log.Fatalf("failed to create destroyer: %s", err)
	}

	destroyServer, err := NewServer(destroyer)
	if err != nil {
		log.Fatalf("failed to create server: %s", err)
	}

	mux := http.NewServeMux()
	mux.Handle("/http", destroyServer.HTTPHandler())
	mux.Handle("/pubsub", destroyServer.PubSubHandler())

	server := &http.Server{
		Addr:    addr,
		Handler: mux,
	}

	go func() {
		log.Printf("server is listening on %s\n", port)
		if err := server.ListenAndServe(); err != http.ErrServerClosed {
			log.Fatalf("server exited: %s", err)
		}
	}()

	signalCh := make(chan os.Signal, 1)
	signal.Notify(signalCh, os.Interrupt)

	<-signalCh

	log.Printf("received stop, shutting down")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("failed to shutdown server: %s", err)
	}
}
