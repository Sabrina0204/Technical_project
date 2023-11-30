import os
import sys
import shutil
from socket import *
import struct
import hashlib
import math
import tqdm
import numpy
from threading import Thread
from threading import Lock
import threading
from multiprocessing.dummy import Pool as ThreadPool
import gzip
import zlib
import zipfile
import time
import json


# Const Value
OP_SAVE, OP_DELETE, OP_GET, OP_UPLOAD, OP_DOWNLOAD, OP_BYE, OP_LOGIN, OP_ERROR = 'SAVE', 'DELETE', 'GET', 'UPLOAD', 'DOWNLOAD', 'BYE', 'LOGIN', "ERROR"
TYPE_FILE, TYPE_DATA, TYPE_AUTH, DIR_EARTH = 'FILE', 'DATA', 'AUTH', 'EARTH'
FIELD_OPERATION, FIELD_DIRECTION, FIELD_TYPE, FIELD_USERNAME, FIELD_PASSWORD, FIELD_TOKEN = 'operation', 'direction', 'type', 'username', 'password', 'token'
FIELD_KEY, FIELD_SIZE, FIELD_TOTAL_BLOCK, FIELD_MD5, FIELD_BLOCK_SIZE = 'key', 'size', 'total_block', 'md5', 'block_size'
FIELD_STATUS, FIELD_STATUS_MSG, FIELD_BLOCK_INDEX = 'status', 'status_msg', 'block_index'
DIR_REQUEST, DIR_RESPONSE = 'REQUEST', 'RESPONSE'

# Server Information
server_ip = '127.0.0.1'
server_port = 1379


# Client Information
username = '2035100'
token = ''
start_time = 0
commandLock = Lock()  # 让四个步骤按序进行
save_total_block = 0
save_block_size = 0
save_md5 = ''
loopCnt = 3  # 记录需要接收的包的数量， 避免接收线程阻塞导致整个进程无法结束
pbar: tqdm.tqdm
mutex = Lock()
thread_pool = ThreadPool(processes=30)


def get_file_md5(filename):
    """
    Get MD5 value for big file
    :param filename:
    :return:
    """
    m = hashlib.md5()
    with open(filename, 'rb') as fid:
        while True:
            d = fid.read(2048)
            if not d:
                break
            m.update(d)
    return m.hexdigest()


def get_text_md5(st):
    """
    Get MD5 value for string
    :param st:
    :return:
    """
    m = hashlib.md5(st.encode())
    return m.hexdigest()


def make_packet(json_data, bin_data=None):
    """
    Make a packet following the STEP protocol.
    Any information or data for TCP transmission has to use this function to get the packet.
    :param json_data:
    :param bin_data:
    :return:
        The complete binary packet
    """
    j = json.dumps(dict(json_data))
    j_len = len(j)
    if bin_data is None:
        return struct.pack('!II', j_len, 0) + j.encode()
    else:
        return struct.pack('!II', j_len, len(bin_data)) + j.encode() + bin_data


def make_request_packet(operation, data_type, json_data, bin_data=None):
    """
    Make a packet for request
    :param operation: [SAVE, DELETE, GET, UPLOAD, DOWNLOAD, BYE, LOGIN]
    :param data_type: [FILE, DATA, AUTH]
    :param json_data
    :param bin_data
    :return:
    """
    json_data[FIELD_OPERATION] = operation
    json_data[FIELD_DIRECTION] = DIR_REQUEST
    json_data[FIELD_TYPE] = data_type
    json_data[FIELD_TOKEN] = token
    json_data[FIELD_USERNAME] = username
    json_data[FIELD_PASSWORD] = get_text_md5(username)
    return make_packet(json_data, bin_data)


def get_tcp_packet(client_socket):
    """
    Receive a complete TCP "packet" from a TCP stream and get the json data and binary data.
    :param client_socket: the TCP connection
    :return:
        json_data
        bin_data
    """
    bin_data = b''
    while len(bin_data) < 8:
        data_rec = client_socket.recv(8)
        if data_rec == b'':
            time.sleep(0.01)
        if data_rec == b'':
            return None, None
        bin_data += data_rec
    data = bin_data[:8]
    bin_data = bin_data[8:]
    j_len, b_len = struct.unpack('!II', data)
    while len(bin_data) < j_len:
        data_rec = client_socket.recv(j_len)
        if data_rec == b'':
            time.sleep(0.01)
        if data_rec == b'':
            return None, None
        bin_data += data_rec
    j_bin = bin_data[:j_len]

    try:
        json_data = json.loads(j_bin.decode())
    except Exception as ex:
        return None, None

    bin_data = bin_data[j_len:]
    while len(bin_data) < b_len:
        data_rec = client_socket.recv(b_len)
        if data_rec == b'':
            time.sleep(0.01)
        if data_rec == b'':
            return None, None
        bin_data += data_rec
    return json_data, bin_data


def client_menu(i):
    """
    Client menu
    input: operation + filepath
    :return:
    """
    file_path = sys.argv[-1]
    idx = file_path.rfind('\\')
    file_name = file_path[idx + 1:]
    if idx == -1:
        file_name = file_path[file_path.rfind('/') + 1:]
    operation = ["LOGIN", "DELETE", "SAVE", "UPLOAD"]
    return operation[i], file_path, file_name


def data_process(response_operation, json_data):
    return None


def file_process(response_operation, json_data, bin_data):
    """
    File Process,
    :param response_operation:
    :param json_data:
    :param bin_data:
    :return:
    Todo: download should store bin_data here
    """
    global save_total_block, pbar
    if response_operation == OP_SAVE:
        save_total_block = json_data[FIELD_TOTAL_BLOCK]
        global loopCnt, save_block_size
        loopCnt += json_data[FIELD_TOTAL_BLOCK]
        save_block_size = json_data[FIELD_BLOCK_SIZE]
        print(json_data[FIELD_STATUS_MSG])
        pbar = tqdm.tqdm(total=save_total_block, desc="Upload progress: ")
        commandLock.release()

    if response_operation == OP_DELETE:
        print(json_data[FIELD_STATUS_MSG])
        commandLock.release()

    if response_operation == OP_GET:
        # if down is needed, file_size total_block should be recorded
        print(json_data[FIELD_STATUS_MSG])
        commandLock.release()

    if response_operation == OP_UPLOAD:
        global start_time, save_md5
        # print(json_data[FIELD_STATUS_MSG] + 'Use time:' + str(int(round(time.time() * 1000)) - start_time) + 'ms')
        mutex.acquire()
        pbar.update(1)
        mutex.release()
        # if int(json_data[FIELD_BLOCK_INDEX]) == save_total_block - 1:
        #     if json_data[FIELD_MD5] == save_md5:
        #         print("md5 is checked ----- OK")
        #     else:
        #         print("md5 check failed")
        #
        #     print('Use time:' + str(int(round(time.time() * 1000)) - start_time) + 'ms')


def step_client(client_socket):
    """
        STEP Protocol client
        :param client_socket:
        :return: None
        """
    global thread_pool
    for i in range(4):
        with commandLock:
            operation, abs_path, file_name = client_menu(i)
        commandLock.acquire()
        if operation == OP_LOGIN:
            client_socket.send(make_request_packet(OP_LOGIN, TYPE_AUTH, {}))

        elif operation == OP_SAVE:
            json_data = {}
            key = file_name
            file_path = abs_path
            json_data[FIELD_KEY] = key
            json_data[FIELD_SIZE] = os.path.getsize(file_path)
            client_socket.send(make_request_packet(OP_SAVE, TYPE_FILE, json_data))

            # test SAVE C:\Users\14332\Desktop\Quan.jpg

        elif operation == OP_DELETE:
            rval = {
                FIELD_KEY: file_name
            }
            client_socket.send(make_request_packet(OP_DELETE, TYPE_FILE, rval))
            # test DELETE Quan.jpg

        elif operation == OP_UPLOAD:
            global save_block_size
            file_path = abs_path
            file_size = os.path.getsize(file_path)
            block_size = save_block_size
            total_block = math.ceil(file_size / block_size)

            for block_index in range(total_block):
                with open(file_path, 'rb') as fid:
                    fid.seek(block_size * block_index)
                    if block_size * (block_index + 1) < file_size:
                        bin_data = fid.read(block_size)
                        if block_index == 1:
                            global start_time
                            start_time = int(round(time.time() * 1000))
                    else:
                        bin_data = fid.read(file_size - block_size * block_index)
                    rval = {
                        FIELD_KEY: file_name,
                        FIELD_BLOCK_INDEX: block_index
                    }
                    global save_md5
                    save_md5 = get_file_md5(file_path)
                    thread_pool.apply(client_socket.send, (make_request_packet(OP_UPLOAD, TYPE_FILE, rval, bin_data),))
                    # send_thread = Thread(target=client_socket.send,
                    #                      args=(make_request_packet(OP_UPLOAD, TYPE_FILE, rval, bin_data),))
                    # send_thread.daemon = False
                    # send_thread.start()

            # test UPLOAD C:\Users\14332\Desktop\Quan.jpg

        elif operation == OP_BYE:
            break

        else:
            continue


def tcp_connector(ip, port):
    """
    TCP Connector: build TCP connect to a server
    :param ip
    :param port
    :return: None
    """
    try:
        client_socket = socket(AF_INET, SOCK_STREAM)
        client_socket.connect((ip, port))
        return client_socket

    except Exception as ex:
        print(ex)


def tcp_receive(client_socket):
    """
        TCP Receive: receive packets from server, and process using new threads
        :param client_socket
        :return: None
        """
    global loopCnt, thread_pool
    while loopCnt > 0:
        loopCnt -= 1
        try:
            json_data, bin_data = get_tcp_packet(client_socket)
            response_type = json_data[FIELD_TYPE]
            request_operation = json_data[FIELD_OPERATION]

            if response_type == TYPE_AUTH:
                global token
                token = json_data[FIELD_TOKEN]
                print(f"Token:{token}")
                commandLock.release()

            if response_type == TYPE_DATA:
                th = Thread(target=data_process, args=(request_operation, json_data))
                # th.daemon = False
                th.start()

            if response_type == TYPE_FILE:
                # thread_pool.apply(file_process, (request_operation, json_data, bin_data))
                th = Thread(target=file_process, args=(request_operation, json_data, bin_data))
                # th.daemon = False
                th.start()

            if loopCnt == 0:
                pbar.close()
                if json_data[FIELD_MD5] == save_md5:
                    print("md5 is checked ----- OK")
                else:
                    print("md5 check failed")

                print('Use time:' + str(int(round(time.time() * 1000)) - start_time) + 'ms')
                commandLock.release()

        except Exception as ex:
            print(ex)


def main():
    if len(sys.argv) != 7:
        sys.exit("argv error")
    global server_ip, username
    server_ip = sys.argv[-5]
    username = sys.argv[-3]
    client_socket = tcp_connector(server_ip, server_port)

    client_thread = Thread(target=step_client, args=(client_socket,))
    client_thread.daemon = False
    client_thread.start()

    receive_thread = Thread(target=tcp_receive, args=(client_socket,))
    receive_thread.daemon = False
    receive_thread.start()


if __name__ == '__main__':
    main()
    # python client.py -server_ip 127.0.0.1 -id 2035100 -f C:\Users\14332\Desktop\Quan.jpg
    # python3 client.py -server_ip 127.0.0.1 -id 2035100 -f /home/can201/Downloads/Quan.jpg
