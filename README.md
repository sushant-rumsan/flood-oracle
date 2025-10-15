## Flood Data Aggregator

- Use registerSource to add a new data source along with its JavaScript code.

- Each source is identified by a unique source ID, which is used to fetch data from that source.

- When requestFloodData is called with a source ID, the corresponding JS code runs via Chainlink Functions, and the result is stored on-chain with a timestamp and hash for reference.
