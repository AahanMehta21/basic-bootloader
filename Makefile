goal: run

run:
	nasm -f bin boot.asm -o boot.com
	bochs -f bochsrc.txt

git:
	@read -p "Enter commit message: " msg; \
	git add .; \
	git commit -m "$$msg"; \
	git branch -M main; \
	git push -u origin main
