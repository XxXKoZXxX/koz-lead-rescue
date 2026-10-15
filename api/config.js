module.exports = function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.setHeader("X-Content-Type-Options", "nosniff");
  if (req.method !== "GET") {
    res.setHeader("Allow", "GET");
    return res.status(405).json({ error: "Method not allowed" });
  }

  const url = process.env.SUPABASE_URL || "";
  const key = process.env.SUPABASE_PUBLISHABLE_KEY || process.env.SUPABASE_ANON_KEY || "";
  const configured = Boolean(url && key);

  return res.status(200).json({
    configured,
    supabaseUrl: configured ? url : null,
    supabaseKey: configured ? key : null
  });
}
