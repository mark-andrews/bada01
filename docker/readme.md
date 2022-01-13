Build docker image from Dockerfile:
```
docker build -t bada01:220113 .
```

Run RStudio server
```
docker run --rm -p 8788:8787 -e PASSWORD=foo -e ROOT=true -v $(dirname $(pwd)):/home/rstudio bada01:220113
```

