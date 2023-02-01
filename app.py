import os
from flask import Flask,request,jsonify
import socket
app = Flask(__name__)
ip=socket.gethostbyname(socket.gethostname())


@app.route("/exe",methods = ['POST'])
def report():
    res=request.json
    cmd='/home/ubuntu/slogr -c '+ res['reciever'] + ' '+res['port']+ ' ' +res['n_packets'] +' '+ res['intervel']+' '+res['w_time'] +' '+res['dscp'] + ' '+ip+' '  +res['p_size']+' '+ res['t_name'] +' ./'
    os.system(cmd)
    return jsonify(cmd)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)
