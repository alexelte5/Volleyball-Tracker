require("dotenv").config();
const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");

const app = express();
const port = process.env.PORT || 5000;

// PostgreSQL Pool erstellen
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// Middleware
app.use(cors());
app.use(express.json());

// APIs
app.get("/teams", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM teams");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.get("/teams/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query("SELECT * FROM teams WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Team not found" });
    }

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.post("/teams", async (req, res) => {
  const { team_name, img_url = null } = req.body;

  if (!team_name) {
    return res.status(400).json({ error: "team_name is required" });
  }

  try {
    const result = await pool.query(
      "INSERT INTO teams (team_name, img_url) VALUES ($1, $2) RETURNING *",
      [team_name, img_url]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

app.put("/teams/:id", async (req, res) => {
  const { id } = req.params;
  const { team_name, img_url } = req.body;

  if (!team_name) {
    return res.status(400).json({ error: "team_name is required" });
  }

  try {
    const result = await pool.query(
      "UPDATE teams SET team_name = $1, img_url = $2 WHERE id = $3 RETURNING *",
      [team_name, img_url, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Team not found" });
    }

    res.status(201).json(result.rows[0])
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.delete("/teams/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query("DELETE FROM teams WHERE id = $1 RETURNING *", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Team not found" });
    }

    res.json({ message: "Team deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

app.get("/players", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM players");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
})

app.get("/players/:team_id", async (req, res) => {
  const { team_id } = req.params;

  try {
    const result = await pool.query(
      "SELECT * FROM players WHERE team_id = $1",
      [team_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Team not found" });
    }

    res.status(200).json(result.rows)
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.post("/players", async (req, res) => {
  const { team_id, first_name = null, last_name = null, birth_date = null, jersey_number = null, position = null, profile_img = null } = req.body;

  if (!team_id) {
    return res.status(400).json({ error: "team_id is required" });
  }

  if (!first_name && !last_name && !jersey_number) {
    return res.status(400).json({ error: "player must have an indicator (first_name/last_name/jersey_number)" });
  }

  try {
    const result = await pool.query(
      "INSERT INTO players (team_id, first_name, last_name, birth_date, jersey_number, position, profile_img) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
      [team_id, first_name, last_name, birth_date, jersey_number, position, profile_img]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.put("/players/:id", async (req, res) => {
  const { id } = req.params;
  const { team_id, first_name = null, last_name = null, birth_date = null, jersey_number = null, position = null, profile_img = null } = req.body;

  if (!id) {
    return res.status(400).json({ error: "team_id is required" });
  }

  if (!first_name && !last_name && !jersey_number) {
    return res.status(400).json({ error: "Player must have an indicator (first_name/last_name/jersey_number)" });
  }

  try {
    const result = await pool.query(
      "UPDATE players SET team_id = $1, first_name = $2, last_name = $3, birth_date = $4, jersey_number = $5, position = $6, profile_img = $7 WHERE id = $8 RETURNING *",
      [team_id, first_name, last_name, birth_date, jersey_number, position, profile_img, id]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.delete("/players/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query("DELETE FROM players WHERE id = $1 RETURNING *", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    res.json({ message: "Player deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

// Server starten
app.listen(port, () => {
  console.log(`Server läuft auf http://localhost:${port}`);
});