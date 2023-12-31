start-postgres:
	docker run --name postgres-nest -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16.0

stop-postgres:
	docker stop postgres-nest

remove-postgres:
	docker rm postgres-nest

remove-containers:
	docker container prune -f

compose-up:
	docker-compose up -d

compose-down:
	docker-compose down

build:
	pack build task-management --builder gcr.io/buildpacks/builder:latest

.PHONY: start-postgres stop-postgres remove-postgres remove-containers compose-up compose-down build