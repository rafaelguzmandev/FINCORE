package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

// healthResponse is the body returned by the /health endpoint.
type healthResponse struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

const serviceName = "payment-service"

// healthHandler answers GET /health with a static UP status.
// No database connection is attempted so the service can be health-checked
// independently of the database.
func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(healthResponse{Status: "UP", Service: serviceName})
}

// setupRoutes registers the HTTP handlers and returns the handler.
func setupRoutes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthHandler)
	return mux
}

// dbSettings holds the service-specific database connection settings read from
// the environment. The connection is intentionally not opened here; database
// access is out of scope for this skeleton.
type dbSettings struct {
	Host     string
	Port     string
	Name     string
	User     string
	Password string
}

// loadDBSettings reads service-specific database settings from the environment.
func loadDBSettings() dbSettings {
	return dbSettings{
		Host:     getEnv("POSTGRES_HOST", "localhost"),
		Port:     getEnv("POSTGRES_PORT", "5432"),
		Name:     getEnv("PAYMENT_DB_NAME", "payment_db"),
		User:     getEnv("PAYMENT_DB_USER", "payment_user"),
		Password: getEnv("PAYMENT_DB_PASSWORD", ""),
	}
}

// getEnv returns the value of the environment variable key, or fallback when
// it is unset or empty.
func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	port := getEnv("SERVER_PORT", "8080")

	// Load service-specific database configuration from the environment. The
	// connection is not opened; only the settings are configured.
	db := loadDBSettings()
	log.Printf("configuring database for service %q at %s:%s/%s (user %q)",
		serviceName, db.Host, db.Port, db.Name, db.User)

	srv := &http.Server{
		Addr:    ":" + port,
		Handler: setupRoutes(),
	}

	// Startup: run the HTTP server in the background.
	go func() {
		log.Printf("%s starting on :%s", serviceName, port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	// Shutdown: stop gracefully on SIGINT/SIGTERM.
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Printf("%s shutting down...", serviceName)
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("server forced to shutdown: %v", err)
	}
	log.Printf("%s exited", serviceName)
}
