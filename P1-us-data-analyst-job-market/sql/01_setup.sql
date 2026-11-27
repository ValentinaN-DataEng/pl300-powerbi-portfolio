-- P1 setup: catalog, schema, volume
-- Run in Databricks SQL Editor (Serverless Starter Warehouse)
CREATE CATALOG IF NOT EXISTS portfolio;
CREATE SCHEMA  IF NOT EXISTS portfolio.p1_jobs;
CREATE VOLUME  IF NOT EXISTS portfolio.p1_jobs.raw;
