# GreatSPN for Kitapena

This repository contains a complete `Dockerfile` used to build the base image for the **Kitapena** application. This image contains a fully compiled, standalone **GreatSPN** analytical environment (in particular, C++ tools like `DSPN-Tool` for Continuous-Time Markov Chains).

## Usage

This image serves as the base layer from which subsequent environment layers (e.g., backend, celery) inherit. The image is powered by **Python 3.9** on a minimal version of Debian (`bullseye-slim`).

In the target `Dockerfile` for the new application, simply use the following directive:

```dockerfile
FROM dawidkonarczak/greatspn-for-kitapena:latest
```

To build and overwrite the image locally after making script adjustments here, use the standard command:
```bash
docker build -t dawidkonarczak/greatspn-for-kitapena:latest .
```

To test running the bare tools in the terminal:
```bash
docker run -it --rm dawidkonarczak/greatspn-for-kitapena:latest bash
```
