package config

import (
	"os"
	"path/filepath"
	"strings"
)

const (
	configFileName = "shelloptions.termioptions"
)

// Config represents the shell options configuration
type Config struct {
	ShellPath    string // Path to the preferred shell interpreter
	IgnoreOption bool   // If true, ignore the config file (#ignoreoption)
}

// Default returns a default configuration
func Default() *Config {
	return &Config{
		ShellPath:    "",
		IgnoreOption: false,
	}
}

// Load loads the configuration from the user's home directory
func Load() (*Config, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	configPath := filepath.Join(homeDir, configFileName)
	data, err := os.ReadFile(configPath)
	if err != nil {
		if os.IsNotExist(err) {
			return Default(), nil
		}
		return nil, err
	}

	content := string(data)
	cfg := Default()

	// Check for ignore option
	if strings.Contains(content, "#ignoreoption") {
		cfg.IgnoreOption = true
		return cfg, nil
	}

	// Parse shell path (first non-empty, non-comment line)
	lines := strings.Split(content, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		cfg.ShellPath = line
		break
	}

	return cfg, nil
}

// Save saves the configuration to the user's home directory
func Save(cfg *Config) error {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return err
	}

	configPath := filepath.Join(homeDir, configFileName)
	
	var content string
	if cfg.IgnoreOption {
		content = "#ignoreoption\n"
		if cfg.ShellPath != "" {
			content += cfg.ShellPath + "\n"
		}
	} else {
		content = cfg.ShellPath + "\n"
	}

	return os.WriteFile(configPath, []byte(content), 0644)
}
