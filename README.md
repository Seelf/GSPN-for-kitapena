# GreatSPN for Kitapena

To repozytorium zawiera kompletny `Dockerfile` (oraz towarzyszące pliki konfiguracyjne), służący do budowy obrazu bazowego dla aplikacji **Kitapena**. Obraz ten zawiera w pełni skompilowane, niezależne środowisko analityczne **GreatSPN** (szczególnie narzędzia C++ takie jak `DSPN-Tool` dla ciągłych łańcuchów Markowa). 

## Wykorzystanie

Obraz ten jest bazą, od której dziedziczą kolejne warstwy środowiska (np. backend, celery). Obraz jest obsługiwany przez **Python 3.9** w minimalnej wersji debiana (`bullseye-slim`).

W docelowym `Dockerfile` dla nowej aplikacji wystarczy użyć dyrektywy:

```dockerfile
FROM dawidkonarczak/greatspn-for-kitapena:latest
```

Aby zbudować i nadpisać obraz lokalnie po wprowadzonych tu poprawkach skryptów, użyj standardowej komendy:
```bash
docker build -t dawidkonarczak/greatspn-for-kitapena:latest .
```

Aby przetestować uruchomienie gołych narzędzi w terminalu:
```bash
docker run -it --rm dawidkonarczak/greatspn-for-kitapena:latest bash
```
