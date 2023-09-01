CREATE SCHEMA IF NOT EXISTS `oficina` DEFAULT CHARACTER SET utf8;

CREATE TABLE IF NOT EXISTS `oficina`.`car` (
  `carID` INT NOT NULL AUTO_INCREMENT,
  `model` VARCHAR(45) NOT NULL,
  `maker` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`carID`));

CREATE TABLE IF NOT EXISTS `oficina`.`customer` (
  `customerID` INT NOT NULL AUTO_INCREMENT,
  `fullName` VARCHAR(45) NOT NULL,
  `date_of_birth` DATETIME NOT NULL,
  `CPF` CHAR(11) NOT NULL,
  `phone` VARCHAR(11) NOT NULL,
  PRIMARY KEY (`customerID`),
  CONSTRAINT unique_customer_cpf UNIQUE (CPF));

CREATE TABLE IF NOT EXISTS `oficina`.`customerCar` (
  `carID` INT NOT NULL,
  `customerID` INT NOT NULL,
  PRIMARY KEY (`carID`, `customerID`),
  CONSTRAINT `fk_customer_customerCar`
    FOREIGN KEY (`customerID`)
    REFERENCES `oficina`.`customer` (`customerID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_car_customerCar`
    FOREIGN KEY (`carID`)
    REFERENCES `oficina`.`car` (`carID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);

CREATE TABLE IF NOT EXISTS `oficina`.`employee` (
  `employeeID` INT NOT NULL AUTO_INCREMENT,
  `fullName` VARCHAR(45) NOT NULL,
  `date_of_birth` DATETIME NOT NULL,
  `salary` DECIMAL(4) NOT NULL,
  `job` ENUM('Mecânico', 'Recepcionista', 'Gerente') NOT NULL,
  `CPF` CHAR(11) NOT NULL,
  PRIMARY KEY (`employeeID`),
  CONSTRAINT unique_employee_cpf UNIQUE (CPF));

CREATE TABLE IF NOT EXISTS `oficina`.`service` (
  `serviceID` INT NOT NULL AUTO_INCREMENT,
  `serviceName` VARCHAR(45) NOT NULL,
  `cost` DECIMAL(4) NOT NULL,
  `expectedTime` INT NOT NULL,
  PRIMARY KEY (`serviceID`));
    
CREATE TABLE IF NOT EXISTS `oficina`.`serviceOrder` (
  `serviceOrderID` INT NOT NULL AUTO_INCREMENT,
  `paymentMethod` ENUM('Dinheiro', 'Transferência', 'Cartão de Crédito', 'Cartão de Débito') NULL,
  `customerID` INT NOT NULL,
  `status` ENUM('Aberto', 'Em execução', 'Concluído') NOT NULL DEFAULT 'Aberto',
  `paid` TINYINT NOT NULL DEFAULT 0,
  `carID` INT NOT NULL,
  PRIMARY KEY (`serviceOrderID`),
  CONSTRAINT `fk_serviceOrder_car`
    FOREIGN KEY (`carID`)
    REFERENCES `oficina`.`car` (`carID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);
    
CREATE TABLE IF NOT EXISTS `oficina`.`serviceExecution` (
  `serviceOrderID` INT NOT NULL,
  `serviceID` INT NOT NULL,
  `employeeID` INT NOT NULL,
  PRIMARY KEY (`serviceOrderID`, `serviceID`),
  CONSTRAINT `fk_serviceExecution_service`
    FOREIGN KEY (`serviceID`)
    REFERENCES `oficina`.`service` (`serviceID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_serviceExecution_employee`
    FOREIGN KEY (`employeeID`)
    REFERENCES `oficina`.`employee` (`employeeID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_serviceExecution_serviceOrder`
    FOREIGN KEY (`serviceOrderID`)
    REFERENCES `oficina`.`serviceOrder` (`serviceOrderID`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);

-- Inserção de dados ao BD para testes:
INSERT INTO `oficina`.`car` (`carID`, `model`, `maker`) VALUES (1, 'Palio', 'Fiat'), (2, '408', 'Peugeot'), (3, 'Clio', 'Renault'), (4, 'ix35', 'Hyundai');
INSERT INTO `oficina`.`customer` (`customerID`, `fullName`, `date_of_birth`, `CPF`, `phone`) VALUES (1, 'Joao da Silva', DATE('1980-01-11'), '11111111111', '11999999999'), (2, 'Jose da Silva', DATE('1982-02-22'), '22222222222', '11987654321'), (3, 'Luiz Carlos', DATE('1985-05-05'), '55555555555', '11555555555');
INSERT INTO `oficina`.`customerCar` (`carID`, `customerID`) VALUES (1, 1), (2, 2), (3, 2), (4, 3);
INSERT INTO `oficina`.`employee` (`employeeID`, `fullName`, `date_of_birth`, `salary`, `job`, `CPF`) VALUES (1, 'Manoel da Silva', DATE('1991-01-01'), 3000.00, 'Mecânico', 12345678911), (2, 'Joaquim da Silva', DATE('1992-02-02'), 3500.00, 'Mecânico', 98765432111), (3, 'Pedro Mario', date('1983-03-03'), 2500.00, 'Mecânico', 12233344411);
INSERT INTO `oficina`.`service` (`serviceID`, `serviceName`, `cost`, `expectedTime`) VALUES (1, 'Cambagem', 100.0, 1), (2, 'Alinhamento', 200.0, 1), (3, 'Balanceamento', 50.0, 1), (4, 'Troca de óleo', 200.0, 1), (5, 'Revisão completa', 500.0, 3);
INSERT INTO `oficina`.`serviceOrder` (`serviceOrderID`, `paymentMethod`, `customerID`, `status`, `paid`, `carID`) VALUES (1, NULL, 1, 'Aberto', 0, 1), (2, 'Dinheiro', 2, 'Em execução', 1, 2), (3, NULL, 2, 'Concluído', 0, 3), (4, NULL, 3, 'Em execução', 1, 4);
INSERT INTO `oficina`.`serviceExecution` (`serviceOrderID`, `serviceID`, `employeeID`) VALUES (1, 1, 1), (2, 5, 3), (3, 1, 1), (3, 2, 2), (4, 2, 2), (4, 3, 1);


-- Exemplos de queries
-- Relação cliente - carros:
select c.fullName as 'Nome completo', v.model as 'Modelo' from customer c 
	join car v 
    join customerCar cc 
    where cc.customerID = c.customerID and cc.carID = v.carID;
-- Relação de serviços a serem executados ordenados por empregado responsável:
select e.fullName as 'Nome completo', s.serviceName as 'Serviço', c.model as 'Veículo' from serviceExecution se 
	join employee e
    join service s
    join car c
    join serviceOrder so
    where se.serviceID = s.serviceID and se.employeeID = e.employeeID and so.serviceOrderID = se.serviceOrderID and so.carID = c.carID
    order by e.fullName;
-- Relação de serviços contratados para cada veiculo:
select so.serviceOrderID as 'O.S.', c.model as 'Veículo', s.serviceName as 'Serviço' from serviceOrder so 
    join service s
    join car c
    join serviceExecution se
    where se.serviceID = s.serviceID and so.serviceOrderID = se.serviceOrderID and so.carID = c.carID
    order by c.model;
-- Totalização de valores por serviços:    
select so.serviceOrderID as 'O.S.', c.model as 'Veículo', sum(s.cost) as 'Total' from serviceOrder so 
    join service s
    join car c
    join serviceExecution se
    where se.serviceID = s.serviceID and so.serviceOrderID = se.serviceOrderID and so.carID = c.carID
    group by so.serviceOrderID;