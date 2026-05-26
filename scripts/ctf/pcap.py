from scapy.all import *
import base64

packets = []
flag = b"ITQ{d1d_th3_sh4rk_6Yt3_y04?}"
b64 = base64.b64encode(flag).decode()
chunks = [b64[i:i+4] for i in range(0, len(b64), 4)]

client = "10.0.0.5"
server = "10.0.0.1"

def make_http_get(src, dst, path, user_agent, sport, seq=100, ack=0):
    ip = IP(src=src, dst=dst)
    tcp = TCP(sport=sport, dport=80, flags="PA", seq=seq, ack=ack)
    http = (
        f"GET {path} HTTP/1.1\r\n"
        f"Host: 10.0.0.1\r\n"
        f"User-Agent: {user_agent}\r\n"
        f"Connection: keep-alive\r\n\r\n"
    )
    return ip/tcp/Raw(load=http.encode())

for i, path in enumerate(["/index.html", "/favicon.ico", "/style.css"]):
    pkt = make_http_get(client, server, path,
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                        sport=10001, seq=100 + i*200)
    packets.append(pkt)

ip = IP(src=client, dst=server)
tcp = TCP(sport=10002, dport=80, flags="PA", seq=100, ack=1)
post = (
    "POST /login HTTP/1.1\r\n"
    "Host: 10.0.0.1\r\n"
    "User-Agent: Mozilla/5.0\r\n"
    "Content-Type: application/x-www-form-urlencoded\r\n"
    "Content-Length: 27\r\n\r\n"
    "username=admin&password=ITq{!flag}"
)
packets.append(ip/tcp/Raw(load=post.encode()))

for i, chunk in enumerate(chunks):
    pkt = make_http_get(client, server,
                        f"/report?id={i+1}",
                        f"Syncer/1.0 {chunk}",
                        sport=10003, seq=100 + i*300)
    packets.append(pkt)

wrpcap("challenge.pcap", packets)
print(f"[+] Generado challenge.pcap")
print(f"[+] Flag en Base64: {b64}")
print(f"[+] Fragmentos: {chunks}")
