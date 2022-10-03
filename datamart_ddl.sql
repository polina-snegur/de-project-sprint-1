CREATE TABLE analysis.dm_rfm_segments (
	user_id int4 NOT NULL,
	recency int4 NOT NULL DEFAULT 0,
	frequency int4 NOT NULL DEFAULT 0,
	monetary_value int4 NOT NULL DEFAULT 0,
    CONSTRAINT dm_rfm_segments_pkey PRIMARY KEY (user_id)
);