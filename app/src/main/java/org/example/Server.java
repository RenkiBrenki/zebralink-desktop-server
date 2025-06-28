package org.example;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

class Server implements AutoCloseable {
    private final int PORT = 8090;
    ServerSocket serverSocket;
    BufferedReader reader;
    BufferedWriter writer;
    private boolean running = false;
    private ObjectMapper objectMapper = new ObjectMapper();

    private static String SUCCESS_MESSAGE = "Data received successfully";

    public Server() throws IOException {
        serverSocket = new ServerSocket(PORT);
    }

    public void start() {
        running = true;
        while (running) {
            try {
                Socket client = serverSocket.accept();
                System.out.println("Accepted client " + client.getInetAddress());
                BufferedReader reader =
                        new BufferedReader(new InputStreamReader(client.getInputStream()));
                PrintWriter writer =
                        new PrintWriter(new OutputStreamWriter(client.getOutputStream()));

                setTypeDelay((reader.readLine()));
                System.out.println("Delay set to " + TypeUtil.instance.getDelay());

                String input;
                while ((input = reader.readLine()) != null) {
                    List<Article> articles =
                            objectMapper.readValue(input, new TypeReference<List<Article>>() {});
                    articles.forEach(
                            article ->
                                    TypeUtil.instance.typeString(article.code(), article.count()));

                    writer.println(SUCCESS_MESSAGE);
                    writer.flush();
                }
            } catch (Exception e) {
                if (running) {
                    System.out.println("Error while accepting client connection");
                }
                e.printStackTrace();
            }
        }
    }

    private void setTypeDelay(String delayResponse) {
        try {
            TypeUtil.instance.setDelay(Integer.parseInt(delayResponse));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void close() {
        running = false;
    }
}
