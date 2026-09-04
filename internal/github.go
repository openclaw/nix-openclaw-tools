package internal

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

var (
	HTTPClient    = &http.Client{Timeout: 30 * time.Second}
	GitHubAPIBase = "https://api.github.com"
)

type Release struct {
	TagName string  `json:"tag_name"`
	Assets  []Asset `json:"assets"`
}

type Asset struct {
	Name               string `json:"name"`
	BrowserDownloadURL string `json:"browser_download_url"`
}

func LatestRelease(repo string) (*Release, error) {
	url := fmt.Sprintf("%s/repos/%s/releases/latest", strings.TrimRight(GitHubAPIBase, "/"), repo)
	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Accept", "application/vnd.github+json")
	if token := os.Getenv("GH_TOKEN"); token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp, err := HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("github api %s: %s", resp.Status, string(body))
	}
	var rel Release
	if err := json.NewDecoder(resp.Body).Decode(&rel); err != nil {
		return nil, err
	}
	if rel.TagName == "" {
		return nil, errors.New("missing tag_name in release")
	}
	return &rel, nil
}
