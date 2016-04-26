BEGIN TRANSACTION;

-- Start of IDN Tables --
DROP TABLE IF EXISTS IDN_BASE_TABLE;
CREATE TABLE IDN_BASE_TABLE (
            PRODUCT_NAME VARCHAR(20),
            PRIMARY KEY (PRODUCT_NAME)
);

INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');

DROP TABLE IF EXISTS IDN_OAUTH_CONSUMER_APPS;
DROP SEQUENCE IF EXISTS IDN_OAUTH_CONSUMER_APPS_PK_SEQ;
CREATE SEQUENCE IDN_OAUTH_CONSUMER_APPS_PK_SEQ;
CREATE TABLE IDN_OAUTH_CONSUMER_APPS (
            ID INTEGER DEFAULT NEXTVAL('IDN_OAUTH_CONSUMER_APPS_PK_SEQ'),
            CONSUMER_KEY VARCHAR(255),
            CONSUMER_SECRET VARCHAR(512),
            USERNAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT 0,
            USER_DOMAIN VARCHAR(50),
            APP_NAME VARCHAR(255),
            OAUTH_VERSION VARCHAR(128),
            CALLBACK_URL VARCHAR(1024),
            GRANT_TYPES VARCHAR (1024),
            CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
            PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS IDN_OAUTH1A_REQUEST_TOKEN;
CREATE TABLE IDN_OAUTH1A_REQUEST_TOKEN (
            REQUEST_TOKEN VARCHAR(512),
            REQUEST_TOKEN_SECRET VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            CALLBACK_URL VARCHAR(1024),
            SCOPE VARCHAR(2048),
            AUTHORIZED VARCHAR(128),
            OAUTH_VERIFIER VARCHAR(512),
            AUTHZ_USER VARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (REQUEST_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS IDN_OAUTH1A_ACCESS_TOKEN;
CREATE TABLE IDN_OAUTH1A_ACCESS_TOKEN (
            ACCESS_TOKEN VARCHAR(512),
            ACCESS_TOKEN_SECRET VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR(512),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ACCESS_TOKEN),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS IDN_OAUTH2_ACCESS_TOKEN;
CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN (
            TOKEN_ID VARCHAR (255),
            ACCESS_TOKEN VARCHAR(255),
            REFRESH_TOKEN VARCHAR(255),
            CONSUMER_KEY_ID INTEGER,
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
            USER_TYPE VARCHAR (25),
            GRANT_TYPE VARCHAR (50),
            TIME_CREATED TIMESTAMP,
            REFRESH_TOKEN_TIME_CREATED TIMESTAMP,
            VALIDITY_PERIOD BIGINT,
            REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
            TOKEN_SCOPE_HASH VARCHAR(32),
            TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',
            TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',
            SUBJECT_IDENTIFIER VARCHAR(255),
            PRIMARY KEY (TOKEN_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
            CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TOKEN_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                           TOKEN_STATE,TOKEN_STATE_ID)
);

CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);

CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);

DROP TABLE IF EXISTS IDN_OAUTH2_AUTHORIZATION_CODE;
CREATE TABLE IDN_OAUTH2_AUTHORIZATION_CODE (
            CODE_ID VARCHAR (255),
            AUTHORIZATION_CODE VARCHAR(512),
            CONSUMER_KEY_ID INTEGER,
	          CALLBACK_URL VARCHAR(1024),
            SCOPE VARCHAR(2048),
            AUTHZ_USER VARCHAR (100),
            TENANT_ID INTEGER,
            USER_DOMAIN VARCHAR(50),
	          TIME_CREATED TIMESTAMP,
	          VALIDITY_PERIOD BIGINT,
            STATE VARCHAR (25) DEFAULT 'ACTIVE',
            TOKEN_ID VARCHAR(255),
            SUBJECT_IDENTIFIER VARCHAR(255),
            PRIMARY KEY (CODE_ID),
            FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE;
CREATE TABLE IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
            TOKEN_ID VARCHAR (255),
            TOKEN_SCOPE VARCHAR (60),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
            FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDN_OAUTH2_SCOPE;
DROP SEQUENCE IF EXISTS IDN_OAUTH2_SCOPE_PK_SEQ;
CREATE SEQUENCE IDN_OAUTH2_SCOPE_PK_SEQ;
CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE (
            SCOPE_ID INTEGER DEFAULT NEXTVAL('IDN_OAUTH2_SCOPE_PK_SEQ'),
            SCOPE_KEY VARCHAR(100) NOT NULL,
            NAME VARCHAR(255) NULL,
            DESCRIPTION VARCHAR(512) NULL,
            TENANT_ID INTEGER DEFAULT 0,
	    ROLES VARCHAR (500) NULL,
            PRIMARY KEY (SCOPE_ID)
);

DROP TABLE IF EXISTS IDN_OAUTH2_RESOURCE_SCOPE;
CREATE TABLE IF NOT EXISTS IDN_OAUTH2_RESOURCE_SCOPE (
            RESOURCE_PATH VARCHAR(255) NOT NULL,
            SCOPE_ID INTEGER NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (RESOURCE_PATH),
            FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS IDN_SCIM_GROUP;
DROP SEQUENCE IF EXISTS IDN_SCIM_GROUP_PK_SEQ;
CREATE SEQUENCE IDN_SCIM_GROUP_PK_SEQ;
CREATE TABLE IDN_SCIM_GROUP (
			ID INTEGER DEFAULT NEXTVAL('IDN_SCIM_GROUP_PK_SEQ'),
			TENANT_ID INTEGER NOT NULL,
			ROLE_NAME VARCHAR(255) NOT NULL,
            ATTR_NAME VARCHAR(1024) NOT NULL,
			ATTR_VALUE VARCHAR(1024),
            PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS IDN_OPENID_REMEMBER_ME;
CREATE TABLE IDN_OPENID_REMEMBER_ME (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT 0,
            COOKIE_VALUE VARCHAR(1024),
            CREATED_TIME TIMESTAMP,
            PRIMARY KEY (USER_NAME, TENANT_ID)
);

DROP TABLE IF EXISTS IDN_OPENID_USER_RPS;
CREATE TABLE IDN_OPENID_USER_RPS (
			USER_NAME VARCHAR(255) NOT NULL,
			TENANT_ID INTEGER DEFAULT 0,
			RP_URL VARCHAR(255) NOT NULL,
			TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
			LAST_VISIT DATE NOT NULL,
			VISIT_COUNT INTEGER DEFAULT 0,
			DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
			PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
);

DROP TABLE IF EXISTS IDN_OPENID_ASSOCIATIONS;
CREATE TABLE IDN_OPENID_ASSOCIATIONS (
            HANDLE VARCHAR(255) NOT NULL,
            ASSOC_TYPE VARCHAR(255) NOT NULL,
            EXPIRE_IN TIMESTAMP NOT NULL,
            MAC_KEY VARCHAR(255) NOT NULL,
            ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (HANDLE)
);

DROP TABLE IF EXISTS IDN_STS_STORE;
DROP SEQUENCE IF EXISTS IDN_STS_STORE_PK_SEQ;
CREATE SEQUENCE IDN_STS_STORE_PK_SEQ;
CREATE TABLE IDN_STS_STORE (
            ID INTEGER DEFAULT NEXTVAL('IDN_STS_STORE_PK_SEQ'),
            TOKEN_ID VARCHAR(255) NOT NULL,
            TOKEN_CONTENT BYTEA NOT NULL,
            CREATE_DATE TIMESTAMP NOT NULL,
            EXPIRE_DATE TIMESTAMP NOT NULL,
            STATE INTEGER DEFAULT 0,
            PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS IDN_IDENTITY_USER_DATA;
CREATE TABLE IDN_IDENTITY_USER_DATA (
            TENANT_ID INTEGER DEFAULT -1234,
            USER_NAME VARCHAR(255) NOT NULL,
            DATA_KEY VARCHAR(255) NOT NULL,
            DATA_VALUE VARCHAR(255),
            PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)
);

DROP TABLE IF EXISTS IDN_IDENTITY_META_DATA;
CREATE TABLE IDN_IDENTITY_META_DATA (
            USER_NAME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
            METADATA_TYPE VARCHAR(255) NOT NULL,
            METADATA VARCHAR(255) NOT NULL,
            VALID VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
);

DROP TABLE IF EXISTS IDN_THRIFT_SESSION;
CREATE TABLE IDN_THRIFT_SESSION (
            SESSION_ID VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            CREATED_TIME VARCHAR(255) NOT NULL,
            LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (SESSION_ID)
);

DROP TABLE IF EXISTS IDN_AUTH_SESSION_STORE;
CREATE TABLE IDN_AUTH_SESSION_STORE (
            SESSION_ID VARCHAR(100) NOT NULL,
            SESSION_TYPE VARCHAR(100) NOT NULL,
            OPERATION VARCHAR(10) NOT NULL,
            SESSION_OBJECT BYTEA,
            TIME_CREATED BIGINT,
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
	);

DROP TABLE IF EXISTS SP_APP;
DROP SEQUENCE IF EXISTS SP_APP_SEQ;
CREATE SEQUENCE SP_APP_SEQ;
CREATE TABLE SP_APP (
            ID INTEGER DEFAULT NEXTVAL('SP_APP_SEQ'),
            TENANT_ID INTEGER NOT NULL,
            APP_NAME VARCHAR (255) NOT NULL ,
            USER_STORE VARCHAR (255) NOT NULL,
            USERNAME VARCHAR (255) NOT NULL ,
            DESCRIPTION VARCHAR (1024),
	    	    ROLE_CLAIM VARCHAR (512),
            AUTH_TYPE VARCHAR (255) NOT NULL,
            PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),
            IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
            IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
            IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
            IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            SUBJECT_CLAIM_URI VARCHAR (512),
            IS_SAAS_APP CHAR(1) DEFAULT '0',
            IS_DUMB_MODE CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);

DROP TABLE IF EXISTS SP_METADATA;
DROP SEQUENCE IF EXISTS SP_METADATA_SEQ;
CREATE SEQUENCE SP_METADATA_SEQ;
CREATE TABLE SP_METADATA (
            ID INTEGER DEFAULT NEXTVAL('SP_METADATA_SEQ'),
            SP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
            FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS SP_INBOUND_AUTH;
DROP SEQUENCE IF EXISTS SP_INBOUND_AUTH_SEQ;
CREATE SEQUENCE SP_INBOUND_AUTH_SEQ;
CREATE TABLE SP_INBOUND_AUTH (
            ID INTEGER DEFAULT NEXTVAL('SP_INBOUND_AUTH_SEQ'),
            TENANT_ID INTEGER NOT NULL,
            INBOUND_AUTH_KEY VARCHAR (255),
            INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,
            PROP_NAME VARCHAR (255),
            PROP_VALUE VARCHAR (1024) ,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_AUTH_STEP;
DROP SEQUENCE IF EXISTS SP_AUTH_STEP_SEQ;
CREATE SEQUENCE SP_AUTH_STEP_SEQ;
CREATE TABLE SP_AUTH_STEP (
            ID INTEGER DEFAULT NEXTVAL('SP_AUTH_STEP_SEQ'),
            TENANT_ID INTEGER NOT NULL,
	     	STEP_ORDER INTEGER DEFAULT 1,
            APP_ID INTEGER NOT NULL,
            IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
            IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_FEDERATED_IDP;
CREATE TABLE SP_FEDERATED_IDP (
            ID INTEGER NOT NULL,
            TENANT_ID INTEGER NOT NULL,
            AUTHENTICATOR_ID INTEGER NOT NULL,
            PRIMARY KEY (ID, AUTHENTICATOR_ID));

ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_CLAIM_MAPPING;
DROP SEQUENCE IF EXISTS SP_CLAIM_MAPPING_SEQ;
CREATE SEQUENCE SP_CLAIM_MAPPING_SEQ;
CREATE TABLE SP_CLAIM_MAPPING (
	    	ID INTEGER DEFAULT NEXTVAL('SP_CLAIM_MAPPING_SEQ'),
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_CLAIM VARCHAR (512) NOT NULL ,
            SP_CLAIM VARCHAR (512) NOT NULL ,
	   		APP_ID INTEGER NOT NULL,
	    	IS_REQUESTED VARCHAR(128) DEFAULT '0',
	    	DEFAULT_VALUE VARCHAR(255),
            PRIMARY KEY (ID));

ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_ROLE_MAPPING;
DROP SEQUENCE IF EXISTS SP_ROLE_MAPPING_SEQ;
CREATE SEQUENCE SP_ROLE_MAPPING_SEQ;
CREATE TABLE SP_ROLE_MAPPING (
	    	ID INTEGER DEFAULT NEXTVAL('SP_ROLE_MAPPING_SEQ'),
	    	TENANT_ID INTEGER NOT NULL,
	    	IDP_ROLE VARCHAR (255) NOT NULL ,
            SP_ROLE VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_REQ_PATH_AUTH;
DROP SEQUENCE IF EXISTS SP_REQ_PATH_AUTH_SEQ;
CREATE SEQUENCE SP_REQ_PATH_AUTH_SEQ;
CREATE TABLE SP_REQ_PATH_AUTHENTICATOR (
	    	ID INTEGER DEFAULT NEXTVAL('SP_REQ_PATH_AUTH_SEQ'),
	    	TENANT_ID INTEGER NOT NULL,
	    	AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));

ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS SP_PROV_CONNECTOR;
DROP SEQUENCE IF EXISTS SP_PROV_CONNECTOR_SEQ;
CREATE SEQUENCE SP_PROV_CONNECTOR_SEQ;
CREATE TABLE SP_PROVISIONING_CONNECTOR (
	    	ID INTEGER DEFAULT NEXTVAL('SP_PROV_CONNECTOR_SEQ'),
	    	TENANT_ID INTEGER NOT NULL,
            IDP_NAME VARCHAR (255) NOT NULL ,
	    	CONNECTOR_NAME VARCHAR (255) NOT NULL ,
	    	APP_ID INTEGER NOT NULL,
	    	IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',
		BLOCKING CHAR(1) NOT NULL DEFAULT '0',
            PRIMARY KEY (ID));

ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;

DROP TABLE IF EXISTS IDP;
DROP SEQUENCE IF EXISTS IDP_SEQ;
CREATE SEQUENCE IDP_SEQ;
CREATE TABLE IDP (
			ID INTEGER DEFAULT NEXTVAL('IDP_SEQ'),
			TENANT_ID INTEGER,
			NAME VARCHAR(254) NOT NULL,
			IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',
			IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',
			HOME_REALM_ID VARCHAR(254),
			IMAGE BYTEA,
			CERTIFICATE BYTEA,
			ALIAS VARCHAR(254),
			INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',
			INBOUND_PROV_USER_STORE_ID VARCHAR(254),
 			USER_CLAIM_URI VARCHAR(254),
 			ROLE_CLAIM_URI VARCHAR(254),
  			DESCRIPTION VARCHAR (1024),
 			DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),
 			DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),
 			PROVISIONING_ROLE VARCHAR(128),
 			IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',
 			IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',
	                DISPLAY_NAME VARCHAR(255),
			PRIMARY KEY (ID),
			UNIQUE (TENANT_ID, NAME));

INSERT INTO IDP (TENANT_ID, NAME, HOME_REALM_ID) VALUES (-1234, 'LOCAL', 'localhost');

DROP TABLE IF EXISTS IDP_ROLE;
DROP SEQUENCE IF EXISTS IDP_ROLE_SEQ;
CREATE SEQUENCE IDP_ROLE_SEQ;
CREATE TABLE IDP_ROLE (
			ID INTEGER DEFAULT NEXTVAL('IDP_ROLE_SEQ'),
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			ROLE VARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, ROLE),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_ROLE_MAPPING;
DROP SEQUENCE IF EXISTS IDP_ROLE_MAPPING_SEQ;
CREATE SEQUENCE IDP_ROLE_MAPPING_SEQ;
CREATE TABLE IDP_ROLE_MAPPING (
			ID INTEGER DEFAULT NEXTVAL('IDP_ROLE_MAPPING_SEQ'),
			IDP_ROLE_ID INTEGER,
			TENANT_ID INTEGER,
			USER_STORE_ID VARCHAR (253),
			LOCAL_ROLE VARCHAR(253),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_CLAIM;
DROP SEQUENCE IF EXISTS IDP_CLAIM_SEQ;
CREATE SEQUENCE IDP_CLAIM_SEQ;
CREATE TABLE IDP_CLAIM (
			ID INTEGER DEFAULT NEXTVAL('IDP_CLAIM_SEQ'),
			IDP_ID INTEGER,
			TENANT_ID INTEGER,
			CLAIM VARCHAR(254),
			PRIMARY KEY (ID),
			UNIQUE (IDP_ID, CLAIM),
			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_CLAIM_MAPPING;
DROP SEQUENCE IF EXISTS IDP_CLAIM_MAPPING_SEQ;
CREATE SEQUENCE IDP_CLAIM_MAPPING_SEQ;
CREATE TABLE IDP_CLAIM_MAPPING (
			ID INTEGER DEFAULT NEXTVAL('IDP_CLAIM_MAPPING_SEQ'),
			IDP_CLAIM_ID INTEGER,
			TENANT_ID INTEGER,
			LOCAL_CLAIM VARCHAR(253),
		    DEFAULT_VALUE VARCHAR(255),
	    	IS_REQUESTED VARCHAR(128) DEFAULT '0',
			PRIMARY KEY (ID),
			UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
			FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_AUTHENTICATOR;
DROP SEQUENCE IF EXISTS IDP_AUTHENTICATOR_SEQ;
CREATE SEQUENCE IDP_AUTHENTICATOR_SEQ;
CREATE TABLE IDP_AUTHENTICATOR (
            ID INTEGER DEFAULT NEXTVAL('IDP_AUTHENTICATOR_SEQ'),
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '1',
            DISPLAY_NAME VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'samlsso');
INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'IDPProperties');
INSERT INTO IDP_AUTHENTICATOR (TENANT_ID, IDP_ID, NAME) VALUES (-1234, 1, 'passivests');


DROP TABLE IF EXISTS IDP_METADATA;
DROP SEQUENCE IF EXISTS IDP_METADATA_SEQ;
CREATE SEQUENCE IDP_METADATA_SEQ;
CREATE TABLE IDP_METADATA (
            ID INTEGER DEFAULT NEXTVAL('IDP_METADATA_SEQ'),
            IDP_ID INTEGER,
            NAME VARCHAR(255) NOT NULL,
            VALUE VARCHAR(255) NOT NULL,
            DISPLAY_NAME VARCHAR(255),
            TENANT_ID INTEGER DEFAULT -1,
            PRIMARY KEY (ID),
            CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

INSERT INTO IDP_METADATA (IDP_ID, NAME, VALUE, DISPLAY_NAME) VALUES (1, 'SessionIdleTimeout', '20160', 'Session Idle Timeout');
INSERT INTO IDP_METADATA (IDP_ID, NAME, VALUE, DISPLAY_NAME) VALUES (1, 'RememberMeTimeout', '15', 'RememberMe Timeout');

DROP TABLE IF EXISTS IDP_AUTHENTICATOR_PROP;
DROP SEQUENCE IF EXISTS IDP_AUTHENTICATOR_PROP_SEQ;
CREATE SEQUENCE IDP_AUTHENTICATOR_PROP_SEQ;
CREATE TABLE IDP_AUTHENTICATOR_PROPERTY (
            ID INTEGER DEFAULT NEXTVAL('IDP_AUTHENTICATOR_PROP_SEQ'),
            TENANT_ID INTEGER,
            AUTHENTICATOR_ID INTEGER,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2047),
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
            FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE);

INSERT INTO  IDP_AUTHENTICATOR_PROPERTY (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY,PROPERTY_VALUE, IS_SECRET ) VALUES (-1234, 1 , 'IdPEntityId', 'localhost', '0');
INSERT INTO  IDP_AUTHENTICATOR_PROPERTY (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY,PROPERTY_VALUE, IS_SECRET ) VALUES (-1234, 3 , 'IdPEntityId', 'localhost', '0');

DROP TABLE IF EXISTS IDP_PROV_CONFIG;
DROP SEQUENCE IF EXISTS IDP_PROV_CONFIG_SEQ;
CREATE SEQUENCE IDP_PROV_CONFIG_SEQ;
CREATE TABLE IDP_PROVISIONING_CONFIG (
            ID INTEGER DEFAULT NEXTVAL('IDP_PROV_CONFIG_SEQ'),
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,
            IS_ENABLED CHAR (1) DEFAULT '0',
            IS_BLOCKING CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_PROV_CONFIG_PROP;
DROP SEQUENCE IF EXISTS IDP_PROV_CONFIG_PROP_SEQ;
CREATE SEQUENCE IDP_PROV_CONFIG_PROP_SEQ;
CREATE TABLE IDP_PROV_CONFIG_PROPERTY (
            ID INTEGER DEFAULT NEXTVAL('IDP_PROV_CONFIG_PROP_SEQ'),
            TENANT_ID INTEGER,
            PROVISIONING_CONFIG_ID INTEGER,
            PROPERTY_KEY VARCHAR(255) NOT NULL,
            PROPERTY_VALUE VARCHAR(2048),
            PROPERTY_BLOB_VALUE BYTEA,
            PROPERTY_TYPE CHAR(32) NOT NULL,
            IS_SECRET CHAR (1) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_PROV_ENTITY;
DROP SEQUENCE IF EXISTS IDP_PROV_ENTITY_SEQ;
CREATE SEQUENCE IDP_PROV_ENTITY_SEQ;
CREATE TABLE IDP_PROVISIONING_ENTITY (
            ID INTEGER DEFAULT NEXTVAL('IDP_PROV_ENTITY_SEQ'),
            PROVISIONING_CONFIG_ID INTEGER,
            ENTITY_TYPE VARCHAR(255) NOT NULL,
            ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,
            ENTITY_NAME VARCHAR(255) NOT NULL,
            ENTITY_VALUE VARCHAR(255),
            TENANT_ID INTEGER,
            ENTITY_LOCAL_ID VARCHAR(255),
            PRIMARY KEY (ID),
            UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
            UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
            FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDP_LOCAL_CLAIM;
DROP SEQUENCE IF EXISTS IDP_LOCAL_CLAIM_SEQ;
CREATE SEQUENCE IDP_LOCAL_CLAIM_SEQ;
CREATE TABLE IF NOT EXISTS IDP_LOCAL_CLAIM(
            ID INTEGER DEFAULT NEXTVAL('IDP_LOCAL_CLAIM_SEQ'),
            TENANT_ID INTEGER,
            IDP_ID INTEGER,
            CLAIM_URI VARCHAR(255) NOT NULL,
            DEFAULT_VALUE VARCHAR(255),
	        IS_REQUESTED VARCHAR(128) DEFAULT '0',
            PRIMARY KEY (ID),
            UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE);

DROP TABLE IF EXISTS IDN_ASSOCIATED_ID;
DROP SEQUENCE IF EXISTS IDN_ASSOCIATED_ID_SEQ;
CREATE SEQUENCE IDN_ASSOCIATED_ID_SEQ;
CREATE TABLE IDN_ASSOCIATED_ID (
            ID INTEGER DEFAULT NEXTVAL('IDN_ASSOCIATED_ID_SEQ'),
	    IDP_USER_ID VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER DEFAULT -1234,
	    IDP_ID INTEGER NOT NULL,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
 	    USER_NAME VARCHAR(255) NOT NULL,
	    PRIMARY KEY (ID),
            UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
            FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS IDN_USER_ACCOUNT_ASSOCIATION;
CREATE TABLE IDN_USER_ACCOUNT_ASSOCIATION (
            ASSOCIATION_KEY VARCHAR(255) NOT NULL,
            TENANT_ID INTEGER,
            DOMAIN_NAME VARCHAR(255) NOT NULL,
            USER_NAME VARCHAR(255) NOT NULL,
            PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME));

DROP TABLE IF EXISTS FIDO_DEVICE_STORE;
CREATE TABLE FIDO_DEVICE_STORE (
        TENANT_ID INTEGER,
        DOMAIN_NAME VARCHAR(255) NOT NULL,
        USER_NAME VARCHAR(45) NOT NULL,
	TIME_REGISTERED TIMESTAMP,
        KEY_HANDLE VARCHAR(200) NOT NULL,
        DEVICE_DATA VARCHAR(2048) NOT NULL,
      PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE));

DROP TABLE IF EXISTS WF_REQUEST;
CREATE TABLE WF_REQUEST (
    UUID VARCHAR (45),
    CREATED_BY VARCHAR (255),
    TENANT_ID INTEGER DEFAULT -1,
    OPERATION_TYPE VARCHAR (50),
    CREATED_AT TIMESTAMP,
    UPDATED_AT TIMESTAMP,
    STATUS VARCHAR (30),
    REQUEST BYTEA,
    PRIMARY KEY (UUID)
);

DROP TABLE IF EXISTS WF_BPS_PROFILE;
CREATE TABLE WF_BPS_PROFILE (
    PROFILE_NAME VARCHAR(45),
    HOST_URL_MANAGER VARCHAR(45),
    HOST_URL_WORKER VARCHAR(45),
    USERNAME VARCHAR(45),
    PASSWORD VARCHAR(255),
    CALLBACK_HOST VARCHAR (45),
    CALLBACK_USERNAME VARCHAR (45),
    CALLBACK_PASSWORD VARCHAR (255),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (PROFILE_NAME, TENANT_ID)
);

DROP TABLE IF EXISTS WF_WORKFLOW;
CREATE TABLE WF_WORKFLOW(
    ID VARCHAR (45),
    WF_NAME VARCHAR (45),
    DESCRIPTION VARCHAR (255),
    TEMPLATE_ID VARCHAR (45),
    IMPL_ID VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (ID)
);

DROP TABLE IF EXISTS WF_WORKFLOW_ASSOCIATION;
DROP SEQUENCE IF EXISTS WF_WORKFLOW_ASSOCIATION_PK_SEQ;
CREATE SEQUENCE WF_WORKFLOW_ASSOCIATION_PK_SEQ;
CREATE TABLE WF_WORKFLOW_ASSOCIATION(
    ID INTEGER DEFAULT NEXTVAL('WF_WORKFLOW_ASSOCIATION_PK_SEQ'),
    ASSOC_NAME VARCHAR (45),
    EVENT_ID VARCHAR(45),
    ASSOC_CONDITION VARCHAR (2000),
    WORKFLOW_ID VARCHAR (45),
    IS_ENABLED CHAR (1) DEFAULT '1',
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY(ID),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
);

DROP TABLE IF EXISTS WF_WORKFLOW_CONFIG_PARAM;
CREATE TABLE WF_WORKFLOW_CONFIG_PARAM(
    WORKFLOW_ID VARCHAR (45),
    PARAM_NAME VARCHAR (45),
    PARAM_VALUE VARCHAR (1000),
    PARAM_QNAME VARCHAR (45),
    PARAM_HOLDER VARCHAR (45),
    TENANT_ID INTEGER DEFAULT -1,
    PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
    FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
);

DROP TABLE IF EXISTS WF_REQUEST_ENTITY_RELATIONSHIP;
CREATE TABLE WF_REQUEST_ENTITY_RELATIONSHIP(
  REQUEST_ID VARCHAR (45),
  ENTITY_NAME VARCHAR (255),
  ENTITY_TYPE VARCHAR (50),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
);

DROP TABLE IF EXISTS WF_WORKFLOW_REQUEST_RELATION;
CREATE TABLE WF_WORKFLOW_REQUEST_RELATION(
  RELATIONSHIP_ID VARCHAR (45),
  WORKFLOW_ID VARCHAR (45),
  REQUEST_ID VARCHAR (45),
  UPDATED_AT TIMESTAMP,
  STATUS VARCHAR (30),
  TENANT_ID INTEGER DEFAULT -1,
  PRIMARY KEY (RELATIONSHIP_ID),
  FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
  FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
);

-- End of IDENTITY Tables--

CREATE SEQUENCE AM_SUBSCRIBER_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_SUBSCRIBER (
    SUBSCRIBER_ID INTEGER DEFAULT nextval('am_subscriber_sequence'),
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EMAIL_ADDRESS VARCHAR(256) NULL,
    DATE_SUBSCRIBED DATE NOT NULL,
    CREATED_BY VARCHAR(100),
    CREATED_TIME DATE,
    UPDATED_BY VARCHAR(100),
    UPDATED_TIME DATE,
    PRIMARY KEY (SUBSCRIBER_ID),
    UNIQUE (TENANT_ID,USER_ID)
)
;

CREATE SEQUENCE AM_APPLICATION_SEQUENCE START WITH 1 INCREMENT BY 1 ;
CREATE TABLE AM_APPLICATION (
    APPLICATION_ID INTEGER DEFAULT nextval('am_application_sequence'),
    NAME VARCHAR(100),
    SUBSCRIBER_ID INTEGER,
    APPLICATION_TIER VARCHAR(50) DEFAULT 'Unlimited',
    CALLBACK_URL VARCHAR(512),
    DESCRIPTION VARCHAR(512),
    APPLICATION_STATUS VARCHAR(50) DEFAULT 'APPROVED',
    GROUP_ID VARCHAR(100),
    CREATED_BY VARCHAR(100),
    CREATED_TIME DATE,
    UPDATED_BY VARCHAR(100),
    UPDATED_TIME DATE,
    UUID VARCHAR(256),
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID),
    UNIQUE (NAME,SUBSCRIBER_ID),
    UNIQUE (UUID)
)
;

CREATE SEQUENCE AM_API_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_API (
    API_ID INTEGER DEFAULT nextval('am_api_sequence'),
    API_PROVIDER VARCHAR(256),
    API_NAME VARCHAR(256),
    API_VERSION VARCHAR(30),
    CONTEXT VARCHAR(256),
    CONTEXT_TEMPLATE VARCHAR(256),
    CREATED_BY VARCHAR(100),
    CREATED_TIME DATE,
    UPDATED_BY VARCHAR(100),
    UPDATED_TIME DATE,
    PRIMARY KEY(API_ID),
    UNIQUE (API_PROVIDER,API_NAME,API_VERSION)
)
;

CREATE SEQUENCE AM_API_URL_MAPPING_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_API_URL_MAPPING (
    URL_MAPPING_ID INTEGER DEFAULT nextval('am_api_url_mapping_sequence'),
    API_ID INTEGER NOT NULL,
    HTTP_METHOD VARCHAR(20) NULL,
    AUTH_SCHEME VARCHAR(50) NULL,
    URL_PATTERN VARCHAR(512) NULL,
    THROTTLING_TIER varchar(512) DEFAULT NULL,
    MEDIATION_SCRIPT BYTEA,
    PRIMARY KEY(URL_MAPPING_ID)
)
;

CREATE SEQUENCE AM_SUBSCRIPTION_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_SUBSCRIPTION (
    SUBSCRIPTION_ID INTEGER DEFAULT nextval('am_subscription_sequence'),
    TIER_ID VARCHAR(50),
    API_ID INTEGER,
    LAST_ACCESSED DATE NULL,
    APPLICATION_ID INTEGER,
    SUB_STATUS VARCHAR(50),
    SUBS_CREATE_STATE VARCHAR(50) DEFAULT 'SUBSCRIBE',
    CREATED_BY VARCHAR(100),
    CREATED_TIME DATE,
    UPDATED_BY VARCHAR(100),
    UPDATED_TIME DATE,
    UUID VARCHAR(256),
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (SUBSCRIPTION_ID),
    UNIQUE (UUID)
)
;

CREATE TABLE AM_SUBSCRIPTION_KEY_MAPPING (
    SUBSCRIPTION_ID INTEGER,
    ACCESS_TOKEN VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    FOREIGN KEY(SUBSCRIPTION_ID) REFERENCES AM_SUBSCRIPTION(SUBSCRIPTION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(SUBSCRIPTION_ID,ACCESS_TOKEN)
)
;

CREATE TABLE AM_APPLICATION_KEY_MAPPING (
    APPLICATION_ID INTEGER,
    CONSUMER_KEY VARCHAR(512),
    KEY_TYPE VARCHAR(512) NOT NULL,
    STATE VARCHAR(30),
    CREATE_MODE VARCHAR(30) DEFAULT 'CREATED',
    FOREIGN KEY(APPLICATION_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY(APPLICATION_ID,KEY_TYPE)
)
;

CREATE SEQUENCE AM_APPLICATION_REGISTRATION_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE IF NOT EXISTS AM_APPLICATION_REGISTRATION (
    REG_ID INTEGER DEFAULT nextval('am_application_registration_sequence'),
    SUBSCRIBER_ID INT,
    WF_REF VARCHAR(255) NOT NULL,
    APP_ID INT,
    TOKEN_TYPE VARCHAR(30),
    TOKEN_SCOPE VARCHAR(256) DEFAULT 'default',
    INPUTS VARCHAR(1000),
    ALLOWED_DOMAINS VARCHAR(256),
    VALIDITY_PERIOD BIGINT,
    UNIQUE (SUBSCRIBER_ID,APP_ID,TOKEN_TYPE),
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(APP_ID) REFERENCES AM_APPLICATION(APPLICATION_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (REG_ID)
)
;



CREATE SEQUENCE AM_API_LC_EVENT_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_API_LC_EVENT (
    EVENT_ID INTEGER DEFAULT nextval('am_api_lc_event_sequence'),
    API_ID INTEGER NOT NULL,
    PREVIOUS_STATE VARCHAR(50),
    NEW_STATE VARCHAR(50) NOT NULL,
    USER_ID VARCHAR(50) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    EVENT_DATE DATE NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (EVENT_ID)
)
;

CREATE TABLE AM_APP_KEY_DOMAIN_MAPPING (
   CONSUMER_KEY VARCHAR(255),
   AUTHZ_DOMAIN VARCHAR(255) DEFAULT 'ALL',
   PRIMARY KEY (CONSUMER_KEY,AUTHZ_DOMAIN)
)
;

CREATE SEQUENCE AM_API_COMMENTS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_API_COMMENTS (
    COMMENT_ID INTEGER DEFAULT nextval('am_api_comments_sequence'),
    COMMENT_TEXT VARCHAR(512),
    COMMENTED_USER VARCHAR(255),
    DATE_COMMENTED DATE NOT NULL,
    API_ID INTEGER NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (COMMENT_ID)
)
;

CREATE SEQUENCE AM_WORKFLOWS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_WORKFLOWS(
    WF_ID INTEGER DEFAULT nextval('am_workflows_sequence'),
    WF_REFERENCE VARCHAR(255) NOT NULL,
    WF_TYPE VARCHAR(255) NOT NULL,
    WF_STATUS VARCHAR(255) NOT NULL,
    WF_CREATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    WF_UPDATED_TIME TIMESTAMP DEFAULT CURRENT_TIMESTAMP ,
    WF_STATUS_DESC VARCHAR(1000),
    TENANT_ID INTEGER,
    TENANT_DOMAIN VARCHAR(255),
    WF_EXTERNAL_REFERENCE VARCHAR(255) NOT NULL,
    PRIMARY KEY (WF_ID),
    UNIQUE (WF_EXTERNAL_REFERENCE)
)
;

CREATE SEQUENCE AM_API_RATINGS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_API_RATINGS (
    RATING_ID INTEGER DEFAULT nextval('am_api_ratings_sequence'),
    API_ID INTEGER,
    RATING INTEGER,
    SUBSCRIBER_ID INTEGER,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY(SUBSCRIBER_ID) REFERENCES AM_SUBSCRIBER(SUBSCRIBER_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (RATING_ID)
)
;

CREATE SEQUENCE AM_TIER_PERMISSIONS_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_TIER_PERMISSIONS (
    TIER_PERMISSIONS_ID INTEGER DEFAULT nextval('am_tier_permissions_sequence'),
    TIER VARCHAR(50) NOT NULL,
    PERMISSIONS_TYPE VARCHAR(50) NOT NULL,
    ROLES VARCHAR(512) NOT NULL,
    TENANT_ID INTEGER NOT NULL,
    PRIMARY KEY(TIER_PERMISSIONS_ID)
);

CREATE SEQUENCE AM_EXTERNAL_STORES_SEQUENCE START WITH 1 INCREMENT BY 1;
CREATE TABLE AM_EXTERNAL_STORES (
    APISTORE_ID INTEGER DEFAULT nextval('am_external_stores_sequence'),
    API_ID INTEGER,
    STORE_ID VARCHAR(255) NOT NULL,
    STORE_DISPLAY_NAME VARCHAR(255) NOT NULL,
    STORE_ENDPOINT VARCHAR(255) NOT NULL,
    STORE_TYPE VARCHAR(255) NOT NULL,
    FOREIGN KEY(API_ID) REFERENCES AM_API(API_ID) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (APISTORE_ID)
)
;

DROP TABLE IF EXISTS AM_API_SCOPES;
CREATE TABLE IF NOT EXISTS AM_API_SCOPES (
   API_ID  INTEGER NOT NULL,
   SCOPE_ID  INTEGER NOT NULL,
   FOREIGN KEY (API_ID) REFERENCES AM_API (API_ID) ON DELETE CASCADE  ON UPDATE CASCADE,
   FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS AM_API_DEFAULT_VERSION;
DROP SEQUENCE IF EXISTS AM_API_DEFAULT_VERSION_PK_SEQ;
CREATE SEQUENCE AM_API_DEFAULT_VERSION_PK_SEQ;
CREATE TABLE AM_API_DEFAULT_VERSION (
            DEFAULT_VERSION_ID INTEGER DEFAULT NEXTVAL('am_api_default_version_pk_seq'), 
            API_NAME VARCHAR(256) NOT NULL ,
            API_PROVIDER VARCHAR(256) NOT NULL , 
            DEFAULT_API_VERSION VARCHAR(30) , 
            PUBLISHED_DEFAULT_API_VERSION VARCHAR(30) ,
            PRIMARY KEY (DEFAULT_VERSION_ID)
);


CREATE INDEX IDX_SUB_APP_ID ON AM_SUBSCRIPTION (APPLICATION_ID, SUBSCRIPTION_ID)
;

CREATE SEQUENCE AM_ALERT_TYPES_SEQ START WITH 1 INCREMENT BY 1;

CREATE TABLE  AM_ALERT_TYPES (
            ALERT_TYPE_ID INTEGER DEFAULT NEXTVAL('am_alert_types_seq'),
            ALERT_TYPE_NAME VARCHAR(255) NOT NULL ,
	    STAKE_HOLDER VARCHAR(100) NOT NULL,           
            PRIMARY KEY (ALERT_TYPE_ID)
);

CREATE TABLE  AM_ALERT_TYPES_VALUES (
            ALERT_TYPE_ID INTEGER, 
            USER_NAME VARCHAR(255) NOT NULL ,
	    STAKE_HOLDER VARCHAR(100) NOT NULL ,
            PRIMARY KEY (ALERT_TYPE_ID,USER_NAME,STAKE_HOLDER)
);

CREATE SEQUENCE AM_ALERT_EMAILLIST_SEQ START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS AM_ALERT_EMAILLIST (  
	    EMAIL_LIST_ID INTEGER DEFAULT NEXTVAL('am_alert_emaillist_seq'),  
            USER_NAME VARCHAR(255) NOT NULL ,	    
	    STAKE_HOLDER VARCHAR(100) NOT NULL ,
            PRIMARY KEY (EMAIL_LIST_ID,USER_NAME,STAKE_HOLDER)
);

CREATE TABLE IF NOT EXISTS  AM_ALERT_EMAILLIST_DETAILS (             
            EMAIL_LIST_ID INTEGER,
	    EMAIL VARCHAR(255),	    
            PRIMARY KEY (EMAIL_LIST_ID,EMAIL)
);

INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('abnormalResponseTime', 'publisher');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('abnormalBackendTime', 'publisher');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('abnormalRequestsPerMin', 'subscriber');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('RequestPatternChanged', 'subscriber');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('UnusualIPAccessAlert', 'subscriber');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalRefreshAlert', 'subscriber');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('FrequentTierHittingAlert', 'subscriber');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('AbnormalTierUsage', 'publisher');
INSERT INTO AM_ALERT_TYPES (ALERT_TYPE_NAME, STAKE_HOLDER) VALUES ('healthAvailabilityPerMin', 'publisher');

commit;
