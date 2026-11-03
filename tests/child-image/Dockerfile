FROM ghcr.io/santainetwork/node26-alpine:26
# RUN dieksekusi sebagai USER image (container, uid 1000):
# path writable adalah /home/container, bukan / (root-owned)
RUN node --version > /home/container/built-with-node.txt
CMD ["cat", "/home/container/built-with-node.txt"]
