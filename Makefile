

build:
	$(clean_command)
	sudo rm -rf .ansible
	rm -rf .bash_history
	docker-compose up -d --build --remove-orphans

curl:
	$(clean_command)
	chmod +x curl.sh
	./curl.sh

down:
	$(clean_command)
	rm -rf .bash_history
	docker-compose down

exec:
	$(clean_command)
	docker-compose exec controller bash

ps:
	$(clean_command)
	docker-compose ps

up:
	$(clean_command)
	rm -rf .bash_history
	docker-compose up -d --remove-orphans