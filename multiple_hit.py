import os
import subprocess
import multiprocessing
import paramiko
from paramiko.client import SSHClient
from time import sleep

SERVER_IP = '52.7.51.217'
SERVER_USER = 'ec2-user'
SERVER_KEY = '/Users/a67/.ssh/howareyou.pem'

def cmd_start_screen_with_cmd(cmd, screen_name):
    return "screen -AdmS " + screen_name + " " + cmd
    
def cmd_detach_screen(screen_name):
    return "screen -d " + screen_name

def cmd_execute_screen(cmd, screen_name, output_file = None):
    postfix = "\\n'"
    if output_file:
        postfix = " > " + output_file + "\\n'"
    return "screen -SL " + screen_name + " -X stuff $'" + cmd + postfix
    
def cmd_kill_screen(screen_name):
    return 'screen -S ' + screen_name + ' -X quit'
    
def ssh_execute(client, cmd):
    _, std_out, _ = client.exec_command(cmd, get_pty=True)
    return std_out.readlines()

def ssh_execute_no_wait(client, cmd):
    _, std_out, _ = client.exec_command(cmd + ' > /dev/null 2>&1 &', get_pty=True)
    return std_out.readlines()

def ssh_client(server_ip, server_user, server_key):
    client = SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.load_system_host_keys()
    client.connect(server_ip, username=server_user, key_filename=server_key)
    return client

def generateDebugLink():
    client1 = ssh_client(SERVER_IP, SERVER_USER, SERVER_KEY)
    client2 = ssh_client(SERVER_IP, SERVER_USER, SERVER_KEY)
    ssh_execute(client2, 'cd simi && ' +
                cmd_start_screen_with_cmd('psiturk', 'psiturk'))
    ssh_execute(client1, cmd_execute_screen('server on', 'psiturk'))
    ssh_execute(client1, cmd_execute_screen('debug -p', 'psiturk', 'link_raw.txt'))
    ssh_execute(client1, cmd_detach_screen('psiturk'))
    output = ssh_execute(client1, 'cat simi/link_raw.txt')
    client1.close()
    client2.close()
    return output

print generateDebugLink()[1].strip()











