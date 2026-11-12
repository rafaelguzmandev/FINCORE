package main

import (
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHealthEndpointReturnsUp(t *testing.T) {
	handler := setupRoutes()
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	rec := httptest.NewRecorder()

	handler.ServeHTTP(rec, req)

	if rec.Code != http.StatusOK {
		t.Fatalf("expected status %d, got %d", http.StatusOK, rec.Code)
	}

	body, err := io.ReadAll(rec.Body)
	if err != nil {
		t.Fatalf("failed to read response body: %v", err)
	}

	var resp healthResponse
	if err := json.Unmarshal(body, &resp); err != nil {
		t.Fatalf("response is not valid JSON: %v", err)
	}

	if resp.Status != "UP" {
		t.Fatalf("expected status UP, got %q", resp.Status)
	}
	if resp.Service != serviceName {
		t.Fatalf("expected service %q, got %q", serviceName, resp.Service)
	}
}

func TestSetupRoutesReturnsHandler(t *testing.T) {
	if setupRoutes() == nil {
		t.Fatal("setupRoutes returned a nil handler")
	}
}
