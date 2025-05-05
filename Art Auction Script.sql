create database Auctions;
use Auctions;
create table Items(
Item_ID VARCHAR(100),
Item_name VARCHAR(100),
Item_description VARCHAR(200),
Starting_price float,
Artist_ID VARCHAR(100),
primary key(Item_ID)
);
create table Auction(
Auction_ID VARCHAR(100),
Item_ID VARCHAR(200),
Start_time float , 
End_time float ,
Highest_bid float ,
Status VARCHAR(100),
primary key(Auction_ID),
FOREIGN KEY (Item_ID) REFERENCES Items(Item_ID));
SHOW tables;
create table Artists(
Artist_ID VARCHAR(100),
Artist_name VARCHAR(200),
Item_ID VARCHAR(100),
Cert_code int(50),
Email VARCHAR(100),
PRIMARY KEY(Artist_ID),
FOREIGN KEY (Item_ID) REFERENCES Items(Item_ID)
);
show tables;
desc Artists;
create table Bids(
Bid_ID VARCHAR(100),
Item_ID VARCHAR(100),
Artist_ID VARCHAR(100),
Bidder_name VARCHAR(200),
Timestamp TIME(6),
PRIMARY KEY(Bid_ID), 
FOREIGN KEY(Item_ID) REFERENCES Items(Item_ID),
FOREIGN KEY(Artist_ID) REFERENCES Artists(Artist_ID)
);
create table Bidders(
Bidder_ID VARCHAR(200),
Bidder_name VARCHAR(200),
Item_ID VARCHAR(100),
Email VARCHAR(100),
Transaction_ID VARCHAR (100),
PRIMARY KEY(Bidder_ID),
FOREIGN KEY(Item_ID) REFERENCES Items(Item_ID)
);
create table Transactions(
Transaction_ID VARCHAR(100),
Bidder_ID VARCHAR(200),
Total_Amount decimal(65),
Cost decimal(65),
Item_ID VARCHAR(200),
Payment_status VARCHAR(100),
PRIMARY KEY(Transaction_ID),
FOREIGN KEY(Bidder_ID) REFERENCES Bidders(Bidder_ID),
FOREIGN KEY(Item_ID) REFERENCES Items(Item_ID)
);
desc Bidders;
insert INTO Bidders(Bidder_ID,Bidder_name,Item_ID,Email,Transaction_ID) 
VALUES('B001','Amos Gale','I001','amosgale@gmail.com','B001I001'),
('B002','Moses Kuria','I005','moseskuria@gmail.com','B002I005'),
('B003','James Njenga','I001','james24njenga@gmail,com','B003I005'),
('B004','Mia Sesal','I002','mia.fesal@yahoo.com','B004I002'),
('B005','Chris Wairumu','I003','chrissywairumu34@gmail.com','B005I003');
insert INTO Items(Item_ID,Item_name,Item_description,Starting_price,Artist_ID)
VALUES('I001','Painting','white-framed',50000.00,'A001'),
('I002','Piece','1900-teacup',23000.00,'A002'),
('I003','Piece','1700-ashtray',2000000.00,'A001'),
('I004','Painting','LastAshGrayPainting',780000000.00,'A000'),
('I005','Piece','vintagediskplayer',20000.00,'A003'),
('I006','Piece','1400-Discoball',21000.00,'A000');
select * from Bidders;
select * from Items;
insert INTO Transactions(Transaction_ID,Bidder_ID,Total_amount,Cost,Item_ID,Payment_status)
VALUES('B001001','B001',50000.00,47000.00,'I001','Pending'),
('B002I005','B002',20000.00,20000.00,'I005','Paid'),
('B003I001','B003',50000.00,55000.00,'I001','Paid'),
('B004I002','B004',23000.00,20000.00,'I002','Not paid'),
('B005I003','B005',2000000,2000000,'I003','Pending');
select * from Transactions;
select * from Artist;
insert INTO Artists(Artist_ID,Artist_name,Item_ID,Cert_code,Email)
VALUES('A000','Benjamin Jas','I004',0001,'benjamin24jas@gmail.com'),
('A001','Alisa Cory','I006',0002,'Alisa.cory@gmail.com'),
('A002','Ben Carson','I002',0003,'ben.carson@yahoo.com'),
('A003','Ariel Obela','I002',0004,'arielobela@gmail.com');
insert INTO Auction(Auction_ID,Item_ID,Start_time,End_time,Highest_bid,Status)
VALUES('AU001','I005',12.00,13.00,20000.00,'PAID'),
('AU002','I001',19.40,20.20,23000.00,'NOT PAID'),
('AU003','I002',13.00,13.40,55000.00,'PAID'),
('AU004','I001',2340,0000,50000,'Pending'),
('AU005','I003',09.00,09.15,2000000.00,'Paid');
select * from Artists;
drop table Artists;
insert INTO Bids(Bid_ID,Item_ID,Artist_ID,Bidder_name,Timestamp)
VALUES('BD001','I001','A001','Amos Gale',14.00),
('BD002','I005','A002','Moses Kuria',13.00),
('BD003','I001','A001','James Njenga',00.00),
('BD005','I003','A003','Chris Wairimu',09.15);
select * from Bids;
ALTER TABLE Bids ADD Bid_Amount DECIMAL(10, 2);
use Auctions;
DELIMITER //
CREATE TRIGGER UpdateHighestBid
AFTER INSERT ON Bids
FOR EACH ROW
BEGIN
    UPDATE Auction
    SET Highest_bid = NEW.Bid_Amount
    WHERE Item_ID = NEW.Item_ID AND NEW.Bid_Amount > Highest_bid;
END;
//
DELIMITER ;
select * from Auction;
Show tables;
DELIMITER //
CREATE TRIGGER PreventDuplicateBids
BEFORE INSERT ON Bids
FOR EACH ROW
BEGIN
    DECLARE bidExists INT;
    SELECT COUNT(*) INTO bidExists
    FROM Bids
    WHERE Item_ID = NEW.Item_ID AND Bidder_name = NEW.Bidder_name;
    
    IF bidExists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate bid detected for this item.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER UpdateAuctionStatus
AFTER UPDATE ON Auction
FOR EACH ROW
BEGIN
    IF NEW.End_time < CURRENT_TIMESTAMP THEN
        UPDATE Auction
        SET Status = 'Ended'
        WHERE Auction_ID = NEW.Auction_ID;
    END IF;
END;
//
DELIMITER ;
Select * from Auction;
Show Triggers;
CREATE VIEW ActiveAuctions AS
SELECT 
    A.Auction_ID,
    I.Item_name,
    A.Start_time,
    A.End_time,
    A.Highest_bid,
    A.Status
FROM 
    Auction A
JOIN 
    Items I ON A.Item_ID = I.Item_ID
WHERE 
    A.Status = 'Pending' OR A.Status = 'Not Paid';
    CREATE VIEW BidderTransactions AS
SELECT 
    B.Bidder_ID,
    B.Bidder_name,
    B.Email,
    T.Transaction_ID,
    T.Total_Amount,
    T.Payment_status
FROM 
    Bidders B
LEFT JOIN 
    Transactions T ON B.Bidder_ID = T.Bidder_ID;
    CREATE VIEW HighestBids AS
SELECT 
    I.Item_ID,
    I.Item_name,
    MAX(B.Bid_Amount) AS Highest_Bid
FROM 
    Items I
LEFT JOIN 
    Bids B ON I.Item_ID = B.Item_ID
GROUP BY 
    I.Item_ID, I.Item_name;
    
    SELECT * FROM ActiveAuctions;
SELECT * FROM BidderTransactions;
SELECT * FROM ActiveAuctions;
SELECT * FROM HighestBids;