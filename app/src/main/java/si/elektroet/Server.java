package si.elektroet;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.awt.AWTException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.logging.Logger;

class Server implements AutoCloseable {
    private final int PORT = 8090;
    ServerSocket serverSocket;
    BufferedReader reader;
    BufferedWriter writer;
    private boolean running = false;
    private ObjectMapper objectMapper = new ObjectMapper();
    private final TypeUtil typeUtil;
    private final Logger logger;

    private static String SUCCESS_MESSAGE = "Data received successfully";

	
    public Server(Logger logger) throws IOException, AWTException {
        serverSocket = new ServerSocket(PORT);
        this.typeUtil = new TypeUtil();
        this.logger = logger;
    }

    public void start() {
        running = true;
        while (running) {
            try {
                Socket client = serverSocket.accept();
                logger.info("Accepted client " + client.getInetAddress());

                BufferedReader reader =
                        new BufferedReader(new InputStreamReader(client.getInputStream()));
                PrintWriter writer =
                        new PrintWriter(new OutputStreamWriter(client.getOutputStream()));

                setTypeDelay((reader.readLine()));
                logger.info("Delay set to " + typeUtil.getDelay());

                String input;
                while ((input = reader.readLine()) != null) {
                    List<Article> articles =
                            objectMapper.readValue(input, new TypeReference<List<Article>>() {});
                    for (Article article : articles) {
                        if (article.code() != null && article.count() != null) {
                            logger.info(
                                    String.format(
                                            "Entering article: code: %s, count: %s ",
                                            article.code(), article.count()));
                            typeUtil.typeString(article.code(), article.count());
                        } else {
                            logger.info("Article could not be entered, code or count is null");
                        }
                    }

                    writer.println(SUCCESS_MESSAGE);
                    writer.flush();
                }
            } catch (IOException e) {
                if (running) {
                    System.out.println("Error while accepting client connection");
                    e.printStackTrace();
                }
            } catch (NumberFormatException e) {
                logger.info("Failed to set delay, delay is still set to: " + typeUtil.getDelay());
            }
        }
    }

    private void setTypeDelay(String delayResponse) throws NumberFormatException {
        typeUtil.setDelay(Integer.parseInt(delayResponse));
    }

    @Override
    public void close() {
        running = false;
    }
}
