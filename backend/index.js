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

app.get("teams/:id", async (req, res) => {
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
    return res.status(400).json({ error: "team_name is required"});
  }

  try {
    const result = await pool.query (
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
    return res.status(400).json({ error: "team_name is required"});
  }

  try {
    const result = await pool.query(
      "UPDATE teams SET team_name = $1, img_url = $2 WHERE id = $3 RETURNING *",
      [team_name, img_url, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Team not found"});
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

// Server starten
app.listen(port, () => {
    console.log(`Server läuft auf http://localhost:${port}`);
  });