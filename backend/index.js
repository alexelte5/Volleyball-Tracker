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

    res.status(200).json(result.rows[0])
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
});

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

    res.status(200).json(result.rows[0]);
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

app.delete("/players", async (req, res) => {
  try {
    const result = await pool.query("DELETE FROM players");

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "No players found" });
    }

    res.json({ message: "All players deleted successfully" });
  }
  catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

app.get("/matches", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM matches");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.get("/matches/:id", async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM matches WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Match not found" });
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.post("/matches", async (req, res) => {
  const { match_day, team_id1, team_id2, set_score1 = null, set_score2 = null } = req.body;
  const missing = [];

  if (!match_day) missing.push("match_day");
  if (!team_id1) missing.push("team_id1");
  if (!team_id2) missing.push("team_id2");
  if (missing.length > 0) {
    return res.status(400).json({
      error: `The following field(s) are missing: ${missing.join(", ")}`
    });
  }

  try {
    const matchResult = await pool.query(
      "INSERT INTO matches (match_day, team_id1, team_id2, set_score1, set_score2) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [match_day, team_id1, team_id2, set_score1, set_score2]
    );

    const newMatch = matchResult.rows[0];

    const playersTeam1 = await pool.query(
      "SELECT * FROM players WHERE team_id = $1",
      [team_id1]
    );
    const playersTeam2 = await pool.query(
      "SELECT * FROM players WHERE team_id = $1",
      [team_id2]
    );
    const allPlayers = [...playersTeam1.rows, ...playersTeam2.rows];
    const ratingPromises = allPlayers.map(player => {
      return pool.query(
        `INSERT INTO ratings (player_id, match_id, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,) VALUES ($1, $2) RETURNING *`,
        [player.id, newMatch.id]
      );
    });
    await Promise.all(ratingPromises);

    res.status(201).json(newMatch);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

app.put("/matches/:id", async (req, res) => {
  const { id } = req.params;
  const { match_day, team_id1, team_id2, set_score1 = null, set_score2 = null } = req.body;

  if (!match_day) missing.push("match_day");
  if (!team_id1) missing.push("team_id1");
  if (!team_id2) missing.push("team_id2");
  if (missing.length > 0) {
    return res.status(400).json({
      error: `The following field(s) are missing: ${missing.join(", ")}`
    });
  }

  try {
    const result = await pool.query(
      "UPDATE matches SET match_date = $1, team_id1 = $2, team_id2 = $3, set_score1 = $4, set_score2 = $5 WHERE id = $5 RETURNING *",
      [match_day, team_id1, team_id2, set_score1, set_score2, id]
    );

    res.status(200).json(result.rows[0])
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.get("/ratings", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM ratings");
    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.get("/ratings/p/:player_id", async (req, res) => {
  const { player_id } = req.params;

  try {
    const result = await pool.query(
      "SELECT * FROM ratings WHERE player_id = $1",
      [player_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Player not found" });
    }

    res.status(200).json(result.rows)
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.get("/ratings/:player_id/:match_id", async (req, res) => {
  const { player_id, match_id } = req.params;

  try {
    const result = await pool.query(
      "SELECT * FROM ratings WHERE player_id = $1 AND match_id = $2",
      [player_id, match_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "No rating found for this player and match" });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error")
  }
});

app.get("/ratings/m/:match_id", async (req, res) => {
  const { match_id } = req.params;

  try {
    const result = await pool.query(
      "SELECT * FROM ratings WHERE match_id = $1",
      [match_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "No ratings found for this match"});
    }

    res.status(200).json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server Error");
  }
});

app.post("/ratings", async (req, res) => {
  const { player_id, match_id, service_pp = 0, service_p = 0, service_n = 0, service_m = 0, attack_pp = 0, attack_p = 0, attack_n = 0, attack_m = 0, block_pp = 0, block_n = 0, block_m = 0, receive_p = 0, receive_n = 0, receive_m = 0, defense_p = 0, defense_n = 0, defense_m = 0 } = req.body;

  if(!player_id || !match_id) {
    return res.status(404).json({ error: "player_id or match_id missing" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO ratings (player_id, match_id, service_pp, service_p, service_n, service_m, attack_pp, attack_p, attack_n, attack_m, block_pp, block_n, block_m, receive_p, receive_n, receive_m, defense_p, defense_n, defense_m) 
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19)
      RETURNING *`,
      [player_id, match_id, service_pp, service_p, service_n, service_m, attack_pp, attack_p, attack_n, attack_m, block_pp, block_n, block_m, receive_p, receive_n, receive_m, defense_p, defense_n, defense_m]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
});

app.put("/ratings/:id", async (req, res) => {
  const { id } = req.params;
  const { player_id, match_id, service_pp = 0, service_p = 0, service_n = 0, service_m = 0, attack_pp = 0, attack_p = 0, attack_n = 0, attack_m = 0, block_pp = 0, block_n = 0, block_m = 0, receive_p = 0, receive_n = 0, receive_m = 0, defense_p = 0, defense_n = 0, defense_m = 0 } = req.body;

  if (!player_id || !match_id) {
    return res.status(404).json({ error: "player_id or match_id missing" });
  }

  try {
    const result = await pool.query(
      `UPDATE ratings SET player_id = $1, match_id = $2, service_pp = $3, service_p = $4, service_n = $5, service_m = $6, attack_pp = $7, attack_p = $8, attack_n = $9, attack_m = $10, block_pp = $11, block_n = $12, block_m = $13, receive_p = $14, receive_n = $15, receive_m = $16, defense_p = $17, defense_n = $18, defense_m = $19 
      WHERE id = $20 
      RETURNING *`, 
      [player_id, match_id, service_pp, service_p, service_n, service_m, attack_pp, attack_p, attack_n, attack_m, block_pp, block_n, block_m, receive_p, receive_n, receive_m, defense_p, defense_n, defense_m, id]
    );

    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error"); 
  }
});

// Server starten
app.listen(port, () => {
  console.log(`Server läuft auf http://localhost:${port}`);
});