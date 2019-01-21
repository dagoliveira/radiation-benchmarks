/*
 * ClientSocket.cpp
 *
 *  Created on: 19/01/2019
 *      Author: fernando
 */

#include <iostream>
#include <unistd.h>

#include "ClientSocket.h"

namespace radiation {

void ClientSocket::disconnect_host() {
	if (this->connected) {
		shutdown(this->sock, SHUT_RDWR);
		close(this->sock);
		this->connected = false;
		this->sock = -1;
	}
}

ClientSocket::ClientSocket() :
		address(""), connected(false), port(0), sock(-1) {
}

ClientSocket::ClientSocket(std::string address, int port, Log& log) :
		address(address), connected(false), port(port), sock(-1), log(log) {
}

ClientSocket::~ClientSocket() {
	this->disconnect_host();
}

void ClientSocket::connect_host() {
	this->connected = false;
	//create socket if it is not already created
	if (this->sock == -1) {
		//Create socket
		this->sock = socket(AF_INET, SOCK_STREAM, 0);
		if (this->sock == -1) {
			this->log.log_message_exception(
					"CLIENT_SOCKET - Could not create socket");
		}
//		std::cout << "Socket created" << std::endl;
	}

	//plain ip address
	this->server.sin_addr.s_addr = inet_addr(this->address.c_str());
	this->server.sin_family = AF_INET;
	this->server.sin_port = htons(this->port);
	//Connect to remote server
	if (connect(this->sock, (struct sockaddr*) (&this->server),
			sizeof(this->server)) < 0) {
		this->log.log_message_exception(
				"CLIENT_SOCKET - connect failed. Error");
	}
//	std::cout << "Connected\n";
	this->connected = true;
}



} /* namespace radiation */
