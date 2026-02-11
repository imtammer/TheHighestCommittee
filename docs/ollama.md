# Ollama Configuration

**Core Config:** Environment Variables

## Environment Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `OLLAMA_HOST` | Bind address/port (e.g. `0.0.0.0:11434`) | `127.0.0.1:11434` |
| `OLLAMA_ORIGINS` | Allowed CORS origins (e.g. `*`, `http://localhost:8080`) | `127.0.0.1, 0.0.0.0` |
| `OLLAMA_MODELS` | Path to models directory | `~/.ollama/models` |
| `OLLAMA_KEEP_ALIVE` | Duration to keep models loaded | `5m` |
| `OLLAMA_DEBUG` | Enable debug logging | `false` |

## Docker Usage
Default bind is localhost only. To expose to network, use:
```yaml
environment:
  - OLLAMA_HOST=0.0.0.0
```

## Resources
- [Official FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md)
- [Docker Image](https://hub.docker.com/r/ollama/ollama)
