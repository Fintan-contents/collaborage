package com.nablarch.example.app.web.listener;

import nablarch.core.repository.SystemRepository;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class H2SetupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent servletContextEvent) {
        createTable();
        insertData();
    }

    private void createTable() {
        DataSource dataSource = SystemRepository.get("dataSource");
        try {
            Connection connection = dataSource.getConnection();
            connection.createStatement().execute(CREATE_CLIENT);
            connection.createStatement().execute(CREATE_INDUSTRY);
            connection.createStatement().execute(CREATE_PASSWORD_HISTORY);
            connection.createStatement().execute(CREATE_PROJECT);
            connection.createStatement().execute(CREATE_SYSTEM_ACCOUNT);
            connection.createStatement().execute(CREATE_USER);
            connection.createStatement().execute(CREATE_USER_SESSION);
            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        System.out.println(getClass().getSimpleName() + ": create table");
    }

    private void insertData() {
        DataSource dataSource = SystemRepository.get("dataSource");
        try {
            Connection connection = dataSource.getConnection();

            PreparedStatement preparedStatement = connection.prepareStatement("insert into PUBLIC.CLIENT (CLIENT_ID,CLIENT_NAME,INDUSTRY_CODE) values (?, ?, ?)");
            preparedStatement.setInt(1, 1);
            preparedStatement.setString(2, "１株式会社");
            preparedStatement.setString(3, "01");
            preparedStatement.addBatch();
            preparedStatement.setInt(1, 2);
            preparedStatement.setString(2, "２株式会社");
            preparedStatement.setString(3, "02");
            preparedStatement.addBatch();
            preparedStatement.setInt(1, 3);
            preparedStatement.setString(2, "３株式会社");
            preparedStatement.setString(3, "03");
            preparedStatement.addBatch();
            preparedStatement.executeBatch();
            connection.commit();

            preparedStatement = connection.prepareStatement("insert into PUBLIC.INDUSTRY (INDUSTRY_CODE,INDUSTRY_NAME) values (?, ?)");
            preparedStatement.setString(1, "01");
            preparedStatement.setString(2, "農業");
            preparedStatement.addBatch();
            preparedStatement.setString(1, "02");
            preparedStatement.setString(2, "林業");
            preparedStatement.addBatch();
            preparedStatement.setString(1, "03");
            preparedStatement.setString(2, "漁業");
            preparedStatement.addBatch();
            preparedStatement.executeBatch();
            connection.commit();

            preparedStatement = connection.prepareStatement("insert into PUBLIC.SYSTEM_ACCOUNT (USER_ID,LOGIN_ID,USER_PASSWORD,USER_ID_LOCKED,PASSWORD_EXPIRATION_DATE,FAILED_COUNT,EFFECTIVE_DATE_FROM,EFFECTIVE_DATE_TO) values (?, ?, ?, ?, ?, ?, ?, ?)");
            preparedStatement.setInt(1, 105);
            preparedStatement.setString(2, "10000001");
            preparedStatement.setString(3, "nLf7+E3ObKARUBw+6bvSRyfJ9Cy0HCcsa0DqZIE93K0=");
            preparedStatement.setBoolean(4, false);
            preparedStatement.setString(5, "2027-04-10");
            preparedStatement.setInt(6, 0);
            preparedStatement.setString(7, "2013-08-02");
            preparedStatement.setString(8, "2027-04-04");
            preparedStatement.addBatch();
            preparedStatement.executeBatch();
            connection.commit();

            preparedStatement = connection.prepareStatement("insert into PUBLIC.USERS (USER_ID,KANJI_NAME,KANA_NAME) values (?, ?, ?)");
            preparedStatement.setInt(1, 105);
            preparedStatement.setString(2, "一般ユーザ１");
            preparedStatement.setString(3, "イッパンイチ");
            preparedStatement.addBatch();
            preparedStatement.executeBatch();
            connection.commit();

            connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
        System.out.println(getClass().getSimpleName() + ": insert data");
    }

    @Override
    public void contextDestroyed(ServletContextEvent servletContextEvent) {

    }

    private static final String CREATE_CLIENT = "CREATE TABLE PUBLIC.CLIENT (\n" +
            "  CLIENT_ID SERIAL NOT NULL,\n" +
            "  CLIENT_NAME VARCHAR(128) NOT NULL,\n" +
            "  INDUSTRY_CODE CHAR(2) NOT NULL,\n" +
            "  PRIMARY KEY (CLIENT_ID)\n" +
            ")";
    private static final String CREATE_INDUSTRY = "CREATE TABLE PUBLIC.INDUSTRY (\n" +
            "  INDUSTRY_CODE CHAR(2) NOT NULL,\n" +
            "  INDUSTRY_NAME VARCHAR(50),\n" +
            "  PRIMARY KEY (INDUSTRY_CODE)\n" +
            ")";
    private static final String CREATE_PASSWORD_HISTORY = "CREATE TABLE PUBLIC.PASSWORD_HISTORY (\n" +
            "  PASSWORD_HISTORY_ID BIGINT NOT NULL,\n" +
            "  USER_ID INTEGER,\n" +
            "  USER_PASSWORD VARCHAR(44) NOT NULL,\n" +
            "  PRIMARY KEY (PASSWORD_HISTORY_ID)\n" +
            ")";
    private static final String CREATE_PROJECT = "CREATE TABLE PUBLIC.PROJECT (\n" +
            "  PROJECT_ID SERIAL NOT NULL,\n" +
            "  PROJECT_NAME VARCHAR(128) NOT NULL,\n" +
            "  PROJECT_TYPE VARCHAR(128) NOT NULL,\n" +
            "  PROJECT_CLASS VARCHAR(128) NOT NULL,\n" +
            "  PROJECT_START_DATE DATE,\n" +
            "  PROJECT_END_DATE DATE,\n" +
            "  CLIENT_ID INTEGER,\n" +
            "  PROJECT_MANAGER VARCHAR(128),\n" +
            "  PROJECT_LEADER VARCHAR(128),\n" +
            "  USER_ID INTEGER,\n" +
            "  NOTE VARCHAR(512),\n" +
            "  SALES INTEGER,\n" +
            "  COST_OF_GOODS_SOLD INTEGER,\n" +
            "  SGA INTEGER,\n" +
            "  ALLOCATION_OF_CORP_EXPENSES INTEGER,\n" +
            "  VERSION BIGINT NOT NULL DEFAULT 1,\n" +
            "  PRIMARY KEY (PROJECT_ID)\n" +
            ")";
    private static final String CREATE_SYSTEM_ACCOUNT = "CREATE TABLE PUBLIC.SYSTEM_ACCOUNT (\n" +
            "  USER_ID SERIAL NOT NULL,\n" +
            "  LOGIN_ID VARCHAR(20) NOT NULL,\n" +
            "  USER_PASSWORD VARCHAR(44) NOT NULL,\n" +
            "  USER_ID_LOCKED BOOL NOT NULL,\n" +
            "  PASSWORD_EXPIRATION_DATE DATE NOT NULL,\n" +
            "  FAILED_COUNT SMALLINT NOT NULL,\n" +
            "  EFFECTIVE_DATE_FROM DATE,\n" +
            "  EFFECTIVE_DATE_TO DATE,\n" +
            "  LAST_LOGIN_DATE_TIME TIMESTAMP(6),\n" +
            "  VERSION BIGINT NOT NULL DEFAULT 1,\n" +
            "  PRIMARY KEY (USER_ID)\n" +
            ")";
    private static final String CREATE_USER_SESSION = "CREATE TABLE PUBLIC.USER_SESSION (\n" +
            "  SESSION_ID CHAR(100) NOT NULL,\n" +
            "  SESSION_OBJECT BYTEA NOT NULL,\n" +
            "  EXPIRATION_DATETIME TIMESTAMP NOT NULL,\n" +
            "  PRIMARY KEY (SESSION_ID)\n" +
            ")";
    private static final String CREATE_USER = "CREATE TABLE PUBLIC.USERS (\n" +
            "  USER_ID INTEGER NOT NULL,\n" +
            "  KANJI_NAME VARCHAR(128) NOT NULL,\n" +
            "  KANA_NAME VARCHAR(128) NOT NULL,\n" +
            "  PRIMARY KEY (USER_ID)\n" +
            ")";
}
