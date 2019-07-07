-- Syntax to create a table 

-- First create a schema

create schema example;

-- define a table for some dataset

create table example.example_dataset (
	year int
	, starting date
	, countyname varchar(20)
	, countycode int
	, price float
);

-- Load data from <filepath/filname>

copy example.example_dataset from `filepath/filename.csv`
	header csv delimiter e`,`;
