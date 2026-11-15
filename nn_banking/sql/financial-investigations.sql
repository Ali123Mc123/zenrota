CREATE TABLE IF NOT EXISTS nn_finance_moves (
  opKey VARCHAR(96) PRIMARY KEY, accountId INT NOT NULL, delta DECIMAL(15,2) NOT NULL,
  status VARCHAR(16) NOT NULL, reason VARCHAR(128) NOT NULL, counterparty VARCHAR(64) NOT NULL,
  createdAt BIGINT NOT NULL, KEY idx_finance_move_account (accountId,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_audit (
  id INT AUTO_INCREMENT PRIMARY KEY, officer VARCHAR(64) NOT NULL, action VARCHAR(32) NOT NULL,
  caseId INT NOT NULL DEFAULT 0, accountId INT NOT NULL DEFAULT 0, payload LONGTEXT NOT NULL,
  createdAt BIGINT NOT NULL, KEY idx_finance_audit_case (caseId,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_cases (
  id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(96) NOT NULL, officer VARCHAR(64) NOT NULL,
  status VARCHAR(16) NOT NULL DEFAULT 'open', createdAt BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_investigators (
  caseId INT NOT NULL, identifier VARCHAR(64) NOT NULL, PRIMARY KEY(caseId,identifier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_evidence (
  id INT AUTO_INCREMENT PRIMARY KEY, caseId INT NOT NULL, officer VARCHAR(64) NOT NULL,
  kind VARCHAR(24) NOT NULL, payload LONGTEXT NOT NULL, createdAt BIGINT NOT NULL,
  KEY idx_finance_evidence_case (caseId,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_warrants (
  id INT AUTO_INCREMENT PRIMARY KEY, caseId INT NOT NULL, accountId INT NOT NULL,
  action VARCHAR(16) NOT NULL, requester VARCHAR(64) NOT NULL, reviewer VARCHAR(64),
  status VARCHAR(16) NOT NULL DEFAULT 'requested', reason VARCHAR(256) NOT NULL,
  createdAt BIGINT NOT NULL, expiresAt BIGINT NOT NULL,
  KEY idx_finance_warrant_scope (caseId,accountId,action,status,expiresAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_holds (
  holdKey VARCHAR(96) PRIMARY KEY, accountId INT NOT NULL, amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  fullFreeze TINYINT NOT NULL DEFAULT 0, active TINYINT NOT NULL DEFAULT 1,
  caseId INT NOT NULL DEFAULT 0, officer VARCHAR(64) NOT NULL, reason VARCHAR(128) NOT NULL,
  createdAt BIGINT NOT NULL, expiresAt BIGINT NOT NULL DEFAULT 0,
  KEY idx_finance_hold_account (accountId,active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_watches (
  caseId INT NOT NULL, accountId INT NOT NULL, threshold DECIMAL(15,2) NOT NULL DEFAULT 0,
  officer VARCHAR(64) NOT NULL, active TINYINT NOT NULL DEFAULT 1, createdAt BIGINT NOT NULL,
  PRIMARY KEY(caseId,accountId), KEY idx_finance_watch_account (accountId,active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_alerts (
  id INT AUTO_INCREMENT PRIMARY KEY, caseId INT NOT NULL DEFAULT 0, accountId INT NOT NULL,
  kind VARCHAR(32) NOT NULL, payload LONGTEXT NOT NULL, createdAt BIGINT NOT NULL,
  KEY idx_finance_alert_case (caseId,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_chequebooks (
  serial VARCHAR(36) PRIMARY KEY, owner VARCHAR(64) NOT NULL, leaves INT NOT NULL,
  createdAt BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_cheques (
  serial VARCHAR(36) PRIMARY KEY, issuer VARCHAR(64) NOT NULL, accountId INT NOT NULL,
  recipientId INT NOT NULL, amount DECIMAL(15,2) NOT NULL, description VARCHAR(128) NOT NULL,
  displayName VARCHAR(64) NOT NULL, displayAccount VARCHAR(32) NOT NULL, signature VARCHAR(64) NOT NULL,
  issueDate BIGINT NOT NULL, expiresAt BIGINT NOT NULL, createdAt BIGINT NOT NULL,
  status VARCHAR(24) NOT NULL, counterfeit TINYINT NOT NULL DEFAULT 0, quality VARCHAR(24) NOT NULL DEFAULT '',
  initialDetected TINYINT NOT NULL DEFAULT 0, finalDetected TINYINT NOT NULL DEFAULT 0,
  budgetId INT NOT NULL DEFAULT 0, depositedBy VARCHAR(64), depositedAt BIGINT,
  verifyAt BIGINT, bookSerial VARCHAR(36), KEY idx_cheque_issuer (issuer,createdAt),
  KEY idx_cheque_recipient (recipientId,status), KEY idx_cheque_processing (status,verifyAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_cheque_events (
  id INT AUTO_INCREMENT PRIMARY KEY, serial VARCHAR(36) NOT NULL, actor VARCHAR(64) NOT NULL,
  action VARCHAR(32) NOT NULL, payload LONGTEXT NOT NULL, createdAt BIGINT NOT NULL,
  KEY idx_cheque_event_serial (serial,id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS nn_finance_seizures (
  id INT AUTO_INCREMENT PRIMARY KEY, requestKey VARCHAR(64) NOT NULL UNIQUE, caseId INT NOT NULL,
  accountId INT NOT NULL, destinationId INT NOT NULL, amount DECIMAL(15,2) NOT NULL,
  officer VARCHAR(64) NOT NULL, reason VARCHAR(128) NOT NULL, status VARCHAR(16) NOT NULL, holdKey VARCHAR(96) NOT NULL DEFAULT '',
  createdAt BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
