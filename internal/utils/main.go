package utils

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"regexp"
	"strings"
)

// Exit with an error message.
func ExitWithError(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}

// Get the Announcement ID from environment variables or by specifying an url.
func GetAnnouncementID(url string) string {
	value := os.Getenv("ANNOUNCEMENT_ID")
	if len(value) == 0 {
		pattern := regexp.MustCompile(`https?://.*(NDPLP|NDS|NDPTF).+`)
		return strings.ToLower(pattern.FindStringSubmatch(url)[1])
	}
	return value
}

// Download a file to /tmp.
func DownloadFile(url string) (filename string, err error) {
	fmt.Printf("Downloading document file from %q...\n", url)

	// Create temporary file
	tmpdir, err := os.MkdirTemp("", "*")
	if err != nil {
		return
	}
	filename = fmt.Sprintf("%s/%s", tmpdir, path.Base(url))
	file, err := os.Create(filename)
	if err != nil {
		return
	}
	defer file.Close()

	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return
	}
	defer resp.Body.Close()

	// Check server response
	if resp.StatusCode != http.StatusOK {
		err = fmt.Errorf("unable to download file, bad status: %q", resp.Status)
		return
	}

	// Save to file
	_, err = io.Copy(file, resp.Body)
	if err != nil {
		return
	}

	fmt.Printf("The announcement file %q was downloaded to %q successfully!\n", url, filename)
	return
}
