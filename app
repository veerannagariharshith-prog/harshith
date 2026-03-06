import { useState, useRef, useCallback } from "react";
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, AreaChart, Area, RadarChart, Radar,
  PolarGrid, PolarAngleAxis, PolarRadiusAxis
} from "recharts";

/* ═══════════════════════════════════════════════
   DESIGN SYSTEM
═══════════════════════════════════════════════ */
const C = {
  bg: "#141a2f", surface: "#272b37", card: "#8dace6",
  cardHover: "#131C2C", border: "#1A2535", borderBright: "#00E5C030",
  primary: "#8ed7f9", pDim: "#00E5C015", pSoft: "#00E5C040",
  indigo: "#818CF8", amber: "#F59E0B", red: "#d71717",
  green: "#10B981", pink: "#EC4899",
  text: "#E2E8F0", muted: "#ef2f04", dim: "#1E2D3D",
};

const FONT = `
  @import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Mono:ital,wght@0,300;0,400;0,500;1,300&display=swap');
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
  ::-webkit-scrollbar { width: 4px; height: 4px; }
  ::-webkit-scrollbar-track { background: ${C.surface}; }
  ::-webkit-scrollbar-thumb { background: ${C.dim}; border-radius: 2px; }
  @keyframes fadeUp { from { opacity:0; transform:translateY(16px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pulse { 0%,100% { opacity:1; } 50% { opacity:.5; } }
  @keyframes spin { to { transform:rotate(360deg); } }
  @keyframes glow { 0%,100% { box-shadow:0 0 12px ${C.primary}40; } 50% { box-shadow:0 0 28px ${C.primary}80; } }
  @keyframes scan { 0% { transform:translateY(-100%); } 100% { transform:translateY(100vh); } }
  .fadeUp { animation: fadeUp 0.4s ease forwards; }
  .card-link { transition: all 0.2s; cursor:pointer; }
  .card-link:hover { background:${C.cardHover}; border-color:${C.primary}50; transform:translateY(-2px); }
  .glow-btn { animation: glow 2.5s ease-in-out infinite; }
  .spin { animation: spin 1s linear infinite; }
  .pulse { animation: pulse 1.5s ease-in-out infinite; }
  textarea, input, select { outline: none; }
  button { cursor:pointer; }
`;

/* ═══════════════════════════════════════════════
   MOCK DATA
═══════════════════════════════════════════════ */
const CANDIDATES = [
  { id:1, name:"Priya Sharma",      sector:"IT/Software",   role:"Senior Engineer",     score:94, level:3, gender:"Female",   age:28, disability:false, status:"Shortlisted", exp:5, skills:["Python","React","ML"], bias_risk:"Low"    },
  { id:2, name:"James O'Brien",     sector:"IT/Software",   role:"Senior Engineer",     score:87, level:3, gender:"Male",     age:34, disability:false, status:"Interview",   exp:7, skills:["Java","AWS","Docker"],  bias_risk:"Low"    },
  { id:3, name:"Ananya Kapoor",     sector:"Pharma",        role:"Research Scientist",  score:96, level:3, gender:"Female",   age:31, disability:false, status:"Offer",       exp:6, skills:["Clinical","Data","R"],  bias_risk:"Low"    },
  { id:4, name:"Ravi Nair",         sector:"Civil Engg",    role:"Project Manager",     score:81, level:2, gender:"Male",     age:40, disability:false, status:"Level 2",     exp:12,skills:["CAD","AutoCAD","BIM"], bias_risk:"Medium" },
  { id:5, name:"Sarah Thompson",    sector:"Mechanical",    role:"Design Engineer",     score:88, level:3, gender:"Female",   age:26, disability:true,  status:"Interview",   exp:3, skills:["SolidWorks","FEM","CAE"],bias_risk:"Low"    },
  { id:6, name:"Mohammed Al-Amin",  sector:"IT/Software",   role:"Data Scientist",      score:91, level:3, gender:"Male",     age:29, disability:false, status:"Shortlisted", exp:4, skills:["Python","TF","SQL"],   bias_risk:"Low"    },
  { id:7, name:"Fatima Zahra",      sector:"Pharma",        role:"QA Lead",             score:78, level:2, gender:"Female",   age:35, disability:false, status:"Level 2",     exp:8, skills:["GMP","FDA","ISO"],     bias_risk:"Medium" },
  { id:8, name:"Chen Wei",          sector:"IT/Software",   role:"Backend Engineer",    score:85, level:3, gender:"Male",     age:27, disability:false, status:"Interview",   exp:4, skills:["Go","K8s","gRPC"],    bias_risk:"Low"    },
  { id:9, name:"Aisha Osei",        sector:"Civil Engg",    role:"Structural Engineer", score:89, level:3, gender:"Female",   age:32, disability:false, status:"Shortlisted", exp:7, skills:["STAAD","ETABS","SAP"], bias_risk:"Low"    },
  {id:10, name:"Samuel Rodriguez",  sector:"Mechanical",    role:"Manufacturing Eng",   score:74, level:1, gender:"Male",     age:55, disability:true,  status:"Level 1",     exp:25,skills:["Lean","Six Sigma","PLC"],bias_risk:"High" },
];

const DIVERSITY_DATA = {
  gender: [
    { name:"Female", value:44, color:C.pink },
    { name:"Male",   value:52, color:C.indigo },
    { name:"Other",  value:4,  color:C.amber },
  ],
  age: [
    { range:"18-25", count:18 }, { range:"26-35", count:42 },
    { range:"36-45", count:24 }, { range:"46-55", count:11 }, { range:"56+", count:5 },
  ],
  disability: [
    { name:"No Disability", value:91, color:C.primary },
    { name:"With Disability", value:9, color:C.amber },
  ],
  sectorDiv: [
    { sector:"IT/Software", female:38, male:58, other:4 },
    { sector:"Pharma",      female:54, male:44, other:2 },
    { sector:"Civil Engg",  female:29, male:69, other:2 },
    { sector:"Mechanical",  female:22, male:76, other:2 },
  ],
  timeline: [
    { month:"Aug",  score:61 }, { month:"Sep", score:65 },
    { month:"Oct",  score:68 }, { month:"Nov", score:71 },
    { month:"Dec",  score:73 }, { month:"Jan", score:76 },
    { month:"Feb",  score:79 }, { month:"Mar", score:82 },
  ],
};

const COMPANIES = [
  { name:"TechNova Inc",        industry:"IT/Software",  employees:4200, avgSalary:"₹18L–₹35L",  genderRatio:{f:41,m:57,o:2},  diversity:78, rating:4.2, reviews:312, salaryRange:"50k–100k", maleEmployees:2394, femaleEmployees:1722 },
  { name:"BioSynth Pharma",     industry:"Pharma",       employees:1800, avgSalary:"₹12L–₹28L",  genderRatio:{f:56,m:42,o:2},  diversity:85, rating:4.5, reviews:189, salaryRange:"70k–150k", maleEmployees:756,  femaleEmployees:1008 },
  { name:"BuildRight Civil",    industry:"Civil Engg",   employees:890,  avgSalary:"₹8L–₹22L",   genderRatio:{f:24,m:74,o:2},  diversity:58, rating:3.8, reviews:97,  salaryRange:"40k–80k",  maleEmployees:659,  femaleEmployees:214  },
  { name:"MotionWorks Mech",    industry:"Mechanical",   employees:2100, avgSalary:"₹10L–₹24L",  genderRatio:{f:19,m:79,o:2},  diversity:52, rating:3.6, reviews:143, salaryRange:"45k–90k",  maleEmployees:1659, femaleEmployees:399  },
  { name:"DataPulse Analytics", industry:"IT/Software",  employees:620,  avgSalary:"₹22L–₹48L",  genderRatio:{f:48,m:50,o:2},  diversity:91, rating:4.7, reviews:88,  salaryRange:"80k–200k", maleEmployees:310,  femaleEmployees:298  },
];

const PIPELINE_FUNNEL = [
  { stage:"Applied",       count:248, color:C.muted    },
  { stage:"Screened",      count:186, color:C.indigo   },
  { stage:"Level 1 Test",  count:134, color:C.amber    },
  { stage:"Level 2 Test",  count:87,  color:C.primary  },
  { stage:"Level 3 Test",  count:42,  color:C.green    },
  { stage:"Interviewed",   count:18,  color:C.pink     },
  { stage:"Shortlisted",   count:7,   color:C.primary  },
];

const INTERVIEW_QUESTIONS = {
  "IT/Software":   ["Walk me through a challenging system design problem you solved.", "How do you ensure code quality in a fast-paced environment?", "Describe a time you had to learn a new technology quickly.", "How do you approach debugging a complex production issue?", "What's your experience with agile methodologies?"],
  "Pharma":        ["Describe your experience with GMP compliance.", "How have you contributed to regulatory submissions?", "Walk me through a clinical trial you managed.", "How do you ensure data integrity in research?", "Describe your approach to cross-functional collaboration."],
  "Civil Engg":    ["Describe a structurally complex project you led.", "How do you handle budget overruns on-site?", "Explain your approach to quality control.", "How do you manage subcontractors and stakeholders?", "Describe your experience with BIM software."],
  "Mechanical":    ["Walk me through a product you designed from concept to production.", "How do you approach failure mode analysis?", "Describe your experience with manufacturing processes.", "How do you balance design innovation with cost constraints?", "Explain your quality assurance process."],
};

/* ═══════════════════════════════════════════════
   SHARED UI COMPONENTS
═══════════════════════════════════════════════ */
const s = (base, extra={}) => ({ fontFamily:"'Syne', sans-serif", ...base, ...extra });
const mono = (base, extra={}) => ({ fontFamily:"'DM Mono', monospace", ...base, ...extra });

const Card = ({ children, style={}, className="", onClick }) => (
  <div onClick={onClick} className={`card-link ${className}`} style={{
    background:C.card, border:`1px solid ${C.border}`, borderRadius:16,
    padding:"1.25rem", ...style
  }}>{children}</div>
);

const Badge = ({ children, color=C.primary }) => (
  <span style={mono({ fontSize:11, color, background:`${color}18`, border:`1px solid ${color}30`,
    borderRadius:6, padding:"2px 8px", letterSpacing:"0.05em" })}>{children}</span>
);

const StatusBadge = ({ status }) => {
  const map = {
    "Shortlisted":{ c:C.primary }, "Interview":{ c:C.indigo }, "Offer":{ c:C.green },
    "Level 1":{ c:C.muted }, "Level 2":{ c:C.amber }, "Level 3":{ c:C.pink }, "Rejected":{ c:C.red },
  };
  const key = Object.keys(map).find(k => status?.startsWith(k)) || "Level 1";
  const { c } = map[key] || { c: C.muted };
  return <Badge color={c}>{status}</Badge>;
};

const Pill = ({ label, value, color=C.primary }) => (
  <div style={{ display:"flex", alignItems:"center", gap:8 }}>
    <div style={{ width:8, height:8, borderRadius:"50%", background:color, flexShrink:0 }}/>
    <span style={mono({ fontSize:12, color:C.muted })}>{label}</span>
    <span style={s({ fontSize:13, color, marginLeft:"auto", fontWeight:700 })}>{value}</span>
  </div>
);

const ScoreRing = ({ score, size=56, stroke=4 }) => {
  const r = (size-stroke*2)/2, circ = 2*Math.PI*r;
  const color = score>=85 ? C.primary : score>=70 ? C.amber : C.red;
  return (
    <svg width={size} height={size} style={{ transform:"rotate(-90deg)" }}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={C.border} strokeWidth={stroke}/>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke={color} strokeWidth={stroke}
        strokeDasharray={circ} strokeDashoffset={circ*(1-score/100)} strokeLinecap="round"
        style={{ transition:"stroke-dashoffset 0.8s ease" }}/>
      <text x={size/2} y={size/2} textAnchor="middle" dominantBaseline="central"
        style={{ transform:"rotate(90deg)", transformOrigin:`${size/2}px ${size/2}px`,
          fill:color, fontSize:size>48?13:10, fontFamily:"'DM Mono',monospace", fontWeight:500 }}>
        {score}
      </text>
    </svg>
  );
};

const Loader = () => (
  <div style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:16, padding:"3rem" }}>
    <div style={{ width:36, height:36, borderRadius:"50%", border:`3px solid ${C.border}`,
      borderTopColor:C.primary }} className="spin"/>
    <span style={mono({ color:C.muted, fontSize:13 })}>AI analyzing...</span>
  </div>
);

const KpiCard = ({ label, value, sub, color=C.primary, icon }) => (
  <Card style={{ flex:1 }}>
    <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
      <div>
        <div style={mono({ fontSize:11, color:C.muted, letterSpacing:"0.1em", textTransform:"uppercase", marginBottom:8 })}>{label}</div>
        <div style={s({ fontSize:32, fontWeight:800, color, lineHeight:1 })}>{value}</div>
        {sub && <div style={mono({ fontSize:12, color:C.muted, marginTop:6 })}>{sub}</div>}
      </div>
      <div style={{ width:44, height:44, borderRadius:12, background:`${color}15`,
        display:"flex", alignItems:"center", justifyContent:"center", fontSize:20 }}>{icon}</div>
    </div>
  </Card>
);

/* ═══════════════════════════════════════════════
   CLAUDE API HELPER
═══════════════════════════════════════════════ */
async function askClaude(systemPrompt, userPrompt) {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1000,
      system: systemPrompt,
      messages: [{ role:"user", content: userPrompt }],
    }),
  });
  const data = await res.json();
  return data.content?.map(b => b.text || "").join("") || "";
}

/* ═══════════════════════════════════════════════
   VIEW: DASHBOARD
═══════════════════════════════════════════════ */
function DashboardView({ onNav }) {
  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:24 }}>
      {/* KPI Row */}
      <div style={{ display:"flex", gap:16 }}>
        <KpiCard label="Total Applicants" value="248" sub="↑ 32 this week" color={C.primary} icon="👥"/>
        <KpiCard label="Shortlisted" value="7" sub="2.8% conversion" color={C.green} icon="✅"/>
        <KpiCard label="Bias Alerts" value="3" sub="⚠ needs review" color={C.amber} icon="🚨"/>
        <KpiCard label="Diversity Score" value="82%" sub="↑ 4% from last month" color={C.indigo} icon="📊"/>
      </div>

      <div style={{ display:"grid", gridTemplateColumns:"1fr 340px", gap:16 }}>
        {/* Pipeline Funnel */}
        <Card>
          <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:20 })}>🔬 Hiring Pipeline</div>
          {PIPELINE_FUNNEL.map((stage, i) => {
            const pct = (stage.count / PIPELINE_FUNNEL[0].count) * 100;
            return (
              <div key={i} style={{ marginBottom:10 }}>
                <div style={{ display:"flex", justifyContent:"space-between", marginBottom:4 }}>
                  <span style={mono({ fontSize:12, color:C.muted })}>{stage.stage}</span>
                  <span style={mono({ fontSize:12, color:stage.color, fontWeight:500 })}>{stage.count}</span>
                </div>
                <div style={{ height:8, background:C.border, borderRadius:4, overflow:"hidden" }}>
                  <div style={{ height:"100%", width:`${pct}%`, background:stage.color,
                    borderRadius:4, transition:"width 1s ease", opacity:0.85 }}/>
                </div>
              </div>
            );
          })}
        </Card>

        {/* Quick Stats */}
        <div style={{ display:"flex", flexDirection:"column", gap:12 }}>
          {/* Gender split mini pie */}
          <Card style={{ padding:"1rem" }}>
            <div style={s({ fontSize:13, fontWeight:700, color:C.text, marginBottom:12 })}>Gender Distribution</div>
            <ResponsiveContainer width="100%" height={100}>
              <PieChart>
                <Pie data={DIVERSITY_DATA.gender} cx="50%" cy="50%" innerRadius={28} outerRadius={45}
                  dataKey="value" paddingAngle={3}>
                  {DIVERSITY_DATA.gender.map((e,i)=><Cell key={i} fill={e.color}/>)}
                </Pie>
                <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}
                  labelStyle={{ color:C.muted }} itemStyle={{ color:C.text }}/>
              </PieChart>
            </ResponsiveContainer>
            <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
              {DIVERSITY_DATA.gender.map((g,i)=><Pill key={i} label={g.name} value={`${g.value}%`} color={g.color}/>)}
            </div>
          </Card>

          <Card style={{ padding:"1rem" }}>
            <div style={s({ fontSize:13, fontWeight:700, color:C.text, marginBottom:12 })}>Recent Activity</div>
            {[
              { icon:"🧠", text:"Resume AI scored 4 new applicants", t:"2m ago" },
              { icon:"⚠️", text:"Bias flag on JD for Civil Engg role", t:"14m ago" },
              { icon:"✅", text:"Ananya Kapoor — Offer extended", t:"1h ago" },
              { icon:"🎤", text:"AI Interview: James O'Brien completed", t:"3h ago" },
            ].map((a,i)=>(
              <div key={i} style={{ display:"flex", gap:8, marginBottom:10, alignItems:"flex-start" }}>
                <span style={{ fontSize:14 }}>{a.icon}</span>
                <div style={{ flex:1 }}>
                  <div style={mono({ fontSize:11, color:C.text })}>{a.text}</div>
                  <div style={mono({ fontSize:10, color:C.muted })}>{a.t}</div>
                </div>
              </div>
            ))}
          </Card>
        </div>
      </div>

      {/* Diversity Trend */}
      <Card>
        <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:20 })}>📈 Diversity Score Trend</div>
        <ResponsiveContainer width="100%" height={120}>
          <AreaChart data={DIVERSITY_DATA.timeline}>
            <defs>
              <linearGradient id="dg" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor={C.primary} stopOpacity={0.3}/>
                <stop offset="100%" stopColor={C.primary} stopOpacity={0}/>
              </linearGradient>
            </defs>
            <XAxis dataKey="month" tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
            <YAxis domain={[55,90]} tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
            <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}
              labelStyle={{ color:C.muted }} itemStyle={{ color:C.primary }}/>
            <Area type="monotone" dataKey="score" stroke={C.primary} strokeWidth={2} fill="url(#dg)"/>
          </AreaChart>
        </ResponsiveContainer>
      </Card>

      {/* Top Candidates Preview */}
      <Card>
        <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:16 }}>
          <div style={s({ fontSize:14, fontWeight:700, color:C.text })}>🏆 Top Candidates</div>
          <button onClick={()=>onNav("candidates")} style={s({
            background:"none", border:`1px solid ${C.border}`, color:C.primary,
            borderRadius:8, padding:"4px 12px", fontSize:12, cursor:"pointer"
          })}>View All →</button>
        </div>
        <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
          {CANDIDATES.slice(0,4).sort((a,b)=>b.score-a.score).map(c=>(
            <div key={c.id} style={{ display:"flex", alignItems:"center", gap:12, padding:"10px 12px",
              background:C.surface, borderRadius:10, border:`1px solid ${C.border}` }}>
              <ScoreRing score={c.score} size={44}/>
              <div style={{ flex:1 }}>
                <div style={s({ fontSize:14, fontWeight:600, color:C.text })}>{c.name}</div>
                <div style={mono({ fontSize:11, color:C.muted })}>{c.role} · {c.sector}</div>
              </div>
              <StatusBadge status={c.status}/>
              <div style={{ width:60, textAlign:"right" }}>
                <Badge color={c.bias_risk==="Low"?C.green:c.bias_risk==="Medium"?C.amber:C.red}>
                  {c.bias_risk} risk
                </Badge>
              </div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: JD BIAS SCANNER
═══════════════════════════════════════════════ */
function JDScannerView() {
  const [jd, setJd] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const scan = async () => {
    if (!jd.trim()) return;
    setLoading(true); setResult(null);
    try {
      const raw = await askClaude(
        `You are a bias detection expert for hiring. Analyze job descriptions for biased language. 
Return ONLY valid JSON (no markdown, no backticks) with:
{
  "bias_score": number 0-100 (100 = highly biased),
  "overall_verdict": "Low Bias" | "Moderate Bias" | "High Bias",
  "flagged_phrases": [{"phrase": string, "reason": string, "suggestion": string}],
  "positive_notes": [string],
  "rewritten_summary": string,
  "categories": {"gender_bias": number, "age_bias": number, "cultural_bias": number, "disability_bias": number, "socioeconomic_bias": number}
}`,
        `Analyze this job description for bias:\n\n${jd}`
      );
      const clean = raw.replace(/```json|```/g, "").trim();
      setResult(JSON.parse(clean));
    } catch (e) {
      setResult({ error: "Analysis failed. Please try again." });
    }
    setLoading(false);
  };

  const biasColor = (score) => score < 30 ? C.green : score < 60 ? C.amber : C.red;

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20 }}>
      <div style={{ display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ fontSize:28 }}>🔍</div>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>JD Bias Scanner</div>
          <div style={mono({ fontSize:12, color:C.muted })}>Powered by Claude AI · Detect biased language before you post</div>
        </div>
      </div>

      <Card>
        <div style={s({ fontSize:13, fontWeight:600, color:C.muted, marginBottom:10 })}>PASTE YOUR JOB DESCRIPTION</div>
        <textarea value={jd} onChange={e=>setJd(e.target.value)}
          placeholder="e.g. We're looking for a rockstar developer who is young, energetic, and a cultural fit for our fraternity-like team culture..."
          style={mono({ width:"100%", minHeight:160, background:C.surface, border:`1px solid ${C.border}`,
            borderRadius:12, padding:"1rem", color:C.text, fontSize:13, resize:"vertical", lineHeight:1.6 })}/>
        <div style={{ display:"flex", justifyContent:"flex-end", marginTop:12 }}>
          <button onClick={scan} disabled={loading || !jd.trim()} className="glow-btn"
            style={s({ background:C.primary, color:"#000", border:"none", borderRadius:10,
              padding:"10px 28px", fontSize:14, fontWeight:700, opacity:(!jd.trim()||loading)?0.5:1 })}>
            {loading ? "Scanning..." : "⚡ Scan for Bias"}
          </button>
        </div>
      </Card>

      {loading && <Loader/>}

      {result && !result.error && (
        <div style={{ display:"flex", flexDirection:"column", gap:16 }} className="fadeUp">
          {/* Bias Score Header */}
          <Card style={{ background:`${biasColor(result.bias_score)}10`, borderColor:`${biasColor(result.bias_score)}40` }}>
            <div style={{ display:"flex", alignItems:"center", gap:20 }}>
              <div style={{ textAlign:"center" }}>
                <ScoreRing score={result.bias_score} size={80} stroke={6}/>
                <div style={mono({ fontSize:10, color:C.muted, marginTop:4 })}>BIAS SCORE</div>
              </div>
              <div>
                <div style={s({ fontSize:22, fontWeight:800, color:biasColor(result.bias_score) })}>
                  {result.overall_verdict}
                </div>
                <div style={mono({ fontSize:12, color:C.muted, marginTop:4 })}>
                  {result.flagged_phrases?.length || 0} phrases flagged · AI-powered analysis
                </div>
                <div style={{ display:"flex", gap:8, marginTop:12, flexWrap:"wrap" }}>
                  {Object.entries(result.categories||{}).map(([k,v])=>(
                    <div key={k} style={{ display:"flex", flexDirection:"column", alignItems:"center",
                      background:C.surface, borderRadius:8, padding:"6px 12px", gap:2 }}>
                      <span style={mono({ fontSize:10, color:C.muted })}>{k.replace("_"," ")}</span>
                      <span style={s({ fontSize:14, fontWeight:700, color:biasColor(v) })}>{v}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </Card>

          {/* Flagged Phrases */}
          {result.flagged_phrases?.length > 0 && (
            <Card>
              <div style={s({ fontSize:14, fontWeight:700, color:C.red, marginBottom:14 })}>⚠️ Flagged Phrases</div>
              {result.flagged_phrases.map((f,i)=>(
                <div key={i} style={{ marginBottom:16, padding:"12px 14px", background:C.surface,
                  borderLeft:`3px solid ${C.red}`, borderRadius:"0 10px 10px 0" }}>
                  <div style={mono({ fontSize:13, color:C.red, fontWeight:500, marginBottom:4 })}>"{f.phrase}"</div>
                  <div style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>⚡ {f.reason}</div>
                  <div style={mono({ fontSize:12, color:C.green })}>✅ Suggestion: {f.suggestion}</div>
                </div>
              ))}
            </Card>
          )}

          {/* Positive Notes */}
          {result.positive_notes?.length > 0 && (
            <Card>
              <div style={s({ fontSize:14, fontWeight:700, color:C.green, marginBottom:12 })}>✅ What You Got Right</div>
              {result.positive_notes.map((n,i)=>(
                <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6, display:"flex", gap:8 })}>
                  <span style={{ color:C.green }}>•</span>{n}
                </div>
              ))}
            </Card>
          )}

          {/* Rewritten Summary */}
          {result.rewritten_summary && (
            <Card style={{ borderColor:`${C.primary}30` }}>
              <div style={s({ fontSize:14, fontWeight:700, color:C.primary, marginBottom:12 })}>✨ AI-Rewritten Version</div>
              <div style={mono({ fontSize:13, color:C.text, lineHeight:1.7 })}>{result.rewritten_summary}</div>
            </Card>
          )}
        </div>
      )}

      {result?.error && (
        <Card style={{ borderColor:`${C.red}40` }}>
          <div style={mono({ color:C.red })}>{result.error}</div>
        </Card>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: RESUME AI SCREENER
═══════════════════════════════════════════════ */
function ResumeScreenerView() {
  const [resume, setResume] = useState("");
  const [jobRole, setJobRole] = useState("IT/Software");
  const [jobDesc, setJobDesc] = useState("");
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const analyze = async () => {
    if (!resume.trim()) return;
    setLoading(true); setResult(null);
    try {
      const raw = await askClaude(
        `You are an expert HR AI for bias-free hiring. Analyze resumes objectively based only on skills, experience, and qualifications.
Return ONLY valid JSON (no markdown) with:
{
  "overall_score": number 0-100,
  "shortlist_recommendation": "Strong Recommend" | "Recommend" | "Consider" | "Do Not Recommend",
  "category_scores": {"technical_skills": number, "experience_relevance": number, "communication": number, "problem_solving": number, "cultural_potential": number},
  "strengths": [string],
  "gaps": [string],
  "career_path": {"current_level": string, "next_role": string, "skills_to_develop": [string]},
  "test_level_recommendation": "Level 1" | "Level 2" | "Level 3",
  "bias_notes": string
}`,
        `Sector: ${jobRole}\nJob Description: ${jobDesc || "Not provided"}\nResume:\n${resume}`
      );
      const clean = raw.replace(/```json|```/g,"").trim();
      setResult(JSON.parse(clean));
    } catch {
      setResult({ error:"Analysis failed." });
    }
    setLoading(false);
  };

  const radarData = result?.category_scores
    ? Object.entries(result.category_scores).map(([k,v])=>({
        subject: k.replace("_"," ").replace(/\b\w/g,c=>c.toUpperCase()), value: v
      })) : [];

  const recColor = {
    "Strong Recommend":C.green, "Recommend":C.primary, "Consider":C.amber, "Do Not Recommend":C.red
  };

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20 }}>
      <div style={{ display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ fontSize:28 }}>📄</div>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>Resume AI Screener</div>
          <div style={mono({ fontSize:12, color:C.muted })}>Bias-free scoring · Career path mapping · Level recommendation</div>
        </div>
      </div>

      <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16 }}>
        <Card>
          <div style={s({ fontSize:13, fontWeight:600, color:C.muted, marginBottom:10 })}>SECTOR / ROLE</div>
          <select value={jobRole} onChange={e=>setJobRole(e.target.value)}
            style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`, borderRadius:8,
              padding:"8px 12px", color:C.text, fontSize:13, marginBottom:12 })}>
            {["IT/Software","Pharma","Civil Engg","Mechanical","Finance","Healthcare","Other"].map(s=>(
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
          <div style={s({ fontSize:13, fontWeight:600, color:C.muted, marginBottom:8 })}>JOB DESCRIPTION (Optional)</div>
          <textarea value={jobDesc} onChange={e=>setJobDesc(e.target.value)}
            placeholder="Paste job description for better match scoring..."
            style={mono({ width:"100%", minHeight:80, background:C.surface, border:`1px solid ${C.border}`,
              borderRadius:8, padding:"10px", color:C.text, fontSize:12, resize:"vertical" })}/>
        </Card>
        <Card>
          <div style={s({ fontSize:13, fontWeight:600, color:C.muted, marginBottom:10 })}>PASTE RESUME / CV</div>
          <textarea value={resume} onChange={e=>setResume(e.target.value)}
            placeholder="Paste candidate's resume text here..."
            style={mono({ width:"100%", minHeight:150, background:C.surface, border:`1px solid ${C.border}`,
              borderRadius:8, padding:"10px", color:C.text, fontSize:12, resize:"vertical" })}/>
        </Card>
      </div>
      <div style={{ display:"flex", justifyContent:"flex-end" }}>
        <button onClick={analyze} disabled={loading||!resume.trim()} className="glow-btn"
          style={s({ background:C.primary, color:"#000", border:"none", borderRadius:10,
            padding:"10px 28px", fontSize:14, fontWeight:700, opacity:(!resume.trim()||loading)?0.5:1 })}>
          {loading ? "Analyzing..." : "🧠 Analyze Resume"}
        </button>
      </div>

      {loading && <Loader/>}

      {result && !result.error && (
        <div style={{ display:"flex", flexDirection:"column", gap:16 }} className="fadeUp">
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16 }}>
            {/* Score + Recommendation */}
            <Card style={{ display:"flex", flexDirection:"column", alignItems:"center", gap:12, padding:"1.5rem" }}>
              <ScoreRing score={result.overall_score} size={100} stroke={7}/>
              <div style={s({ fontSize:18, fontWeight:800, color: recColor[result.shortlist_recommendation] || C.primary })}>
                {result.shortlist_recommendation}
              </div>
              <Badge color={C.indigo}>{result.test_level_recommendation}</Badge>
              <div style={mono({ fontSize:11, color:C.muted, textAlign:"center" })}>{result.bias_notes}</div>
            </Card>
            {/* Radar Chart */}
            <Card>
              <div style={s({ fontSize:13, fontWeight:700, color:C.text, marginBottom:8 })}>Skill Radar</div>
              <ResponsiveContainer width="100%" height={180}>
                <RadarChart data={radarData}>
                  <PolarGrid stroke={C.border}/>
                  <PolarAngleAxis dataKey="subject" tick={{ fill:C.muted, fontSize:10 }}/>
                  <PolarRadiusAxis domain={[0,100]} tick={false} axisLine={false}/>
                  <Radar dataKey="value" stroke={C.primary} fill={C.primary} fillOpacity={0.2} strokeWidth={2}/>
                </RadarChart>
              </ResponsiveContainer>
            </Card>
          </div>

          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16 }}>
            <Card>
              <div style={s({ fontSize:13, fontWeight:700, color:C.green, marginBottom:10 })}>💪 Strengths</div>
              {result.strengths?.map((s,i)=>(
                <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                  <span style={{ color:C.green }}>▸ </span>{s}
                </div>
              ))}
            </Card>
            <Card>
              <div style={s({ fontSize:13, fontWeight:700, color:C.amber, marginBottom:10 })}>📌 Gaps to Bridge</div>
              {result.gaps?.map((g,i)=>(
                <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                  <span style={{ color:C.amber }}>▸ </span>{g}
                </div>
              ))}
            </Card>
          </div>

          {result.career_path && (
            <Card style={{ borderColor:`${C.primary}30` }}>
              <div style={s({ fontSize:13, fontWeight:700, color:C.primary, marginBottom:12 })}>🚀 Career Path Recommendation</div>
              <div style={{ display:"flex", gap:16, alignItems:"center", flexWrap:"wrap" }}>
                <div style={{ background:C.surface, borderRadius:10, padding:"10px 16px" }}>
                  <div style={mono({ fontSize:10, color:C.muted })}>CURRENT LEVEL</div>
                  <div style={s({ fontSize:14, fontWeight:700, color:C.text })}>{result.career_path.current_level}</div>
                </div>
                <div style={{ fontSize:20, color:C.primary }}>→</div>
                <div style={{ background:C.surface, borderRadius:10, padding:"10px 16px" }}>
                  <div style={mono({ fontSize:10, color:C.muted })}>NEXT ROLE</div>
                  <div style={s({ fontSize:14, fontWeight:700, color:C.primary })}>{result.career_path.next_role}</div>
                </div>
                <div style={{ flex:1 }}>
                  <div style={mono({ fontSize:10, color:C.muted, marginBottom:6 })}>SKILLS TO DEVELOP</div>
                  <div style={{ display:"flex", flexWrap:"wrap", gap:6 }}>
                    {result.career_path.skills_to_develop?.map((sk,i)=>(
                      <Badge key={i} color={C.indigo}>{sk}</Badge>
                    ))}
                  </div>
                </div>
              </div>
            </Card>
          )}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: SKILL TEST PIPELINE
═══════════════════════════════════════════════ */
function SkillTestsView() {
  const [sector, setSector] = useState("IT/Software");
  const levels = [
    {
      level:1, name:"Foundational Screening", color:C.indigo, icon:"📝",
      desc:"Aptitude, reasoning, and domain basics. MCQ format. 30 minutes.",
      tests: ["Logical Reasoning","Quantitative Aptitude","Domain Basics MCQ","Verbal Communication"],
      pass_rate:"74%", avg_score:68
    },
    {
      level:2, name:"Technical Assessment", color:C.amber, icon:"⚙️",
      desc:"Hands-on technical problems, case studies. Domain-specific. 60 minutes.",
      tests: ["Technical Problem Solving","Case Study Analysis","Domain Specific Tasks","Situational Judgment"],
      pass_rate:"52%", avg_score:74
    },
    {
      level:3, name:"Expert Challenge", color:C.primary, icon:"🏆",
      desc:"Advanced simulation, live coding/design/research task. 90 minutes.",
      tests: ["Advanced Simulation","Live Technical Task","Behavioral Assessment","Leadership/Collaboration Scenarios"],
      pass_rate:"38%", avg_score:81
    },
  ];

  const sectorCandidates = CANDIDATES.filter(c=>c.sector===sector);

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20 }}>
      <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>⚡ Multi-Level Skill Pipeline</div>
          <div style={mono({ fontSize:12, color:C.muted })}>3-tier assessment gating · Eliminate unqualified applicants early</div>
        </div>
        <select value={sector} onChange={e=>setSector(e.target.value)}
          style={mono({ background:C.card, border:`1px solid ${C.border}`, borderRadius:8,
            padding:"8px 12px", color:C.text, fontSize:13 })}>
          {["IT/Software","Pharma","Civil Engg","Mechanical"].map(s=><option key={s}>{s}</option>)}
        </select>
      </div>

      {/* Level Cards */}
      <div style={{ display:"grid", gridTemplateColumns:"repeat(3,1fr)", gap:16 }}>
        {levels.map(l=>(
          <Card key={l.level} style={{ borderColor:`${l.color}30` }}>
            <div style={{ display:"flex", alignItems:"center", gap:10, marginBottom:14 }}>
              <div style={{ fontSize:24 }}>{l.icon}</div>
              <div>
                <div style={mono({ fontSize:10, color:l.color })}>LEVEL {l.level}</div>
                <div style={s({ fontSize:14, fontWeight:700, color:C.text })}>{l.name}</div>
              </div>
            </div>
            <div style={mono({ fontSize:11, color:C.muted, marginBottom:14, lineHeight:1.6 })}>{l.desc}</div>
            <div style={{ display:"flex", flexDirection:"column", gap:6, marginBottom:14 }}>
              {l.tests.map((t,i)=>(
                <div key={i} style={{ display:"flex", alignItems:"center", gap:8 }}>
                  <div style={{ width:6, height:6, borderRadius:"50%", background:l.color }}/>
                  <span style={mono({ fontSize:11, color:C.muted })}>{t}</span>
                </div>
              ))}
            </div>
            <div style={{ display:"flex", justifyContent:"space-between", marginTop:"auto",
              padding:"8px 10px", background:C.surface, borderRadius:8 }}>
              <div>
                <div style={mono({ fontSize:10, color:C.muted })}>PASS RATE</div>
                <div style={s({ fontSize:14, fontWeight:700, color:l.color })}>{l.pass_rate}</div>
              </div>
              <div>
                <div style={mono({ fontSize:10, color:C.muted })}>AVG SCORE</div>
                <div style={s({ fontSize:14, fontWeight:700, color:C.text })}>{l.avg_score}</div>
              </div>
              <div>
                <div style={mono({ fontSize:10, color:C.muted })}>CANDIDATES</div>
                <div style={s({ fontSize:14, fontWeight:700, color:C.text })}>
                  {sectorCandidates.filter(c=>c.level>=l.level).length}
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>

      {/* Candidate Progress Table */}
      <Card>
        <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>
          👥 {sector} Candidate Progress
        </div>
        <table style={{ width:"100%", borderCollapse:"collapse" }}>
          <thead>
            <tr style={{ borderBottom:`1px solid ${C.border}` }}>
              {["Candidate","Score","Level Reached","Status","Action"].map(h=>(
                <th key={h} style={mono({ textAlign:"left", fontSize:11, color:C.muted,
                  padding:"8px 12px", letterSpacing:"0.05em" })}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {sectorCandidates.map(c=>(
              <tr key={c.id} style={{ borderBottom:`1px solid ${C.border}30` }}>
                <td style={{ padding:"10px 12px" }}>
                  <div style={s({ fontSize:13, fontWeight:600, color:C.text })}>{c.name}</div>
                  <div style={mono({ fontSize:11, color:C.muted })}>{c.role}</div>
                </td>
                <td style={{ padding:"10px 12px" }}><ScoreRing score={c.score} size={40}/></td>
                <td style={{ padding:"10px 12px" }}>
                  <div style={{ display:"flex", gap:4 }}>
                    {[1,2,3].map(l=>(
                      <div key={l} style={{ width:24, height:24, borderRadius:6, display:"flex",
                        alignItems:"center", justifyContent:"center", fontSize:10,
                        background: c.level>=l ? C.primary : C.surface,
                        color: c.level>=l ? "#000" : C.muted,
                        fontWeight: c.level>=l ? 700 : 400,
                        fontFamily:"'DM Mono',monospace" }}>L{l}</div>
                    ))}
                  </div>
                </td>
                <td style={{ padding:"10px 12px" }}><StatusBadge status={c.status}/></td>
                <td style={{ padding:"10px 12px" }}>
                  <button style={s({ background:`${C.primary}15`, border:`1px solid ${C.primary}40`,
                    color:C.primary, borderRadius:6, padding:"4px 10px", fontSize:11, fontWeight:600 })}>
                    View →
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: CANDIDATES
═══════════════════════════════════════════════ */
function CandidatesView() {
  const [search, setSearch] = useState("");
  const [sectorFilter, setSectorFilter] = useState("All");
  const [sortBy, setSortBy] = useState("score");
  const [selected, setSelected] = useState(null);

  const sectors = ["All", ...new Set(CANDIDATES.map(c=>c.sector))];
  const filtered = CANDIDATES
    .filter(c => (sectorFilter==="All" || c.sector===sectorFilter)
      && (c.name.toLowerCase().includes(search.toLowerCase()) || c.role.toLowerCase().includes(search.toLowerCase())))
    .sort((a,b)=> sortBy==="score" ? b.score-a.score : sortBy==="name" ? a.name.localeCompare(b.name) : b.level-a.level);

  return (
    <div className="fadeUp" style={{ display:"flex", gap:20 }}>
      {/* Main list */}
      <div style={{ flex:1, display:"flex", flexDirection:"column", gap:16 }}>
        <div style={{ display:"flex", gap:12, alignItems:"center", flexWrap:"wrap" }}>
          <input value={search} onChange={e=>setSearch(e.target.value)}
            placeholder="🔍 Search candidates..."
            style={mono({ flex:1, minWidth:180, background:C.card, border:`1px solid ${C.border}`,
              borderRadius:10, padding:"8px 14px", color:C.text, fontSize:13 })}/>
          <select value={sectorFilter} onChange={e=>setSectorFilter(e.target.value)}
            style={mono({ background:C.card, border:`1px solid ${C.border}`, borderRadius:10,
              padding:"8px 12px", color:C.text, fontSize:13 })}>
            {sectors.map(s=><option key={s}>{s}</option>)}
          </select>
          <select value={sortBy} onChange={e=>setSortBy(e.target.value)}
            style={mono({ background:C.card, border:`1px solid ${C.border}`, borderRadius:10,
              padding:"8px 12px", color:C.text, fontSize:13 })}>
            <option value="score">Sort: Score</option>
            <option value="level">Sort: Level</option>
            <option value="name">Sort: Name</option>
          </select>
        </div>

        <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
          {filtered.map((c, idx)=>(
            <div key={c.id} onClick={()=>setSelected(selected?.id===c.id?null:c)} className="card-link"
              style={{ display:"flex", alignItems:"center", gap:14, padding:"12px 16px",
                background: selected?.id===c.id ? C.cardHover : C.card,
                border:`1px solid ${selected?.id===c.id ? C.primary+"60" : C.border}`,
                borderRadius:14, cursor:"pointer" }}>
              <div style={mono({ fontSize:12, color:C.muted, width:20, textAlign:"center" })}>{idx+1}</div>
              <ScoreRing score={c.score} size={48}/>
              <div style={{ flex:1 }}>
                <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                  <span style={s({ fontSize:15, fontWeight:700, color:C.text })}>{c.name}</span>
                  {c.disability && <Badge color={C.amber}>♿ PWD</Badge>}
                </div>
                <div style={mono({ fontSize:11, color:C.muted })}>{c.role} · {c.sector} · {c.exp}y exp</div>
                <div style={{ display:"flex", gap:6, marginTop:6, flexWrap:"wrap" }}>
                  {c.skills.map((sk,i)=><Badge key={i} color={C.indigo}>{sk}</Badge>)}
                </div>
              </div>
              <div style={{ display:"flex", flexDirection:"column", gap:6, alignItems:"flex-end" }}>
                <StatusBadge status={c.status}/>
                <Badge color={c.bias_risk==="Low"?C.green:c.bias_risk==="Medium"?C.amber:C.red}>
                  {c.bias_risk} bias risk
                </Badge>
                <div style={{ display:"flex", gap:3 }}>
                  {[1,2,3].map(l=>(
                    <div key={l} style={{ width:18, height:18, borderRadius:4, fontSize:8,
                      display:"flex", alignItems:"center", justifyContent:"center",
                      background: c.level>=l ? C.primary : C.border,
                      color: c.level>=l ? "#000" : C.muted,
                      fontFamily:"'DM Mono',monospace", fontWeight:700 }}>L{l}</div>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Detail Panel */}
      {selected && (
        <div style={{ width:280, flexShrink:0 }} className="fadeUp">
          <Card style={{ position:"sticky", top:0 }}>
            <div style={{ textAlign:"center", marginBottom:16 }}>
              <div style={{ width:64, height:64, borderRadius:"50%", background:`${C.primary}20`,
                border:`2px solid ${C.primary}40`, display:"flex", alignItems:"center",
                justifyContent:"center", margin:"0 auto 12px", fontSize:24 }}>
                {selected.name.split(" ").map(n=>n[0]).join("")}
              </div>
              <div style={s({ fontSize:16, fontWeight:800, color:C.text })}>{selected.name}</div>
              <div style={mono({ fontSize:11, color:C.muted })}>{selected.role}</div>
              <div style={{ marginTop:8 }}><StatusBadge status={selected.status}/></div>
            </div>

            <div style={{ display:"flex", flexDirection:"column", gap:8, marginBottom:16 }}>
              {[
                ["Sector", selected.sector],
                ["Experience", `${selected.exp} years`],
                ["Gender", selected.gender],
                ["Age", selected.age],
                ["Disability", selected.disability?"Yes":"No"],
                ["Bias Risk", selected.bias_risk],
              ].map(([k,v])=>(
                <div key={k} style={{ display:"flex", justifyContent:"space-between",
                  padding:"6px 0", borderBottom:`1px solid ${C.border}` }}>
                  <span style={mono({ fontSize:11, color:C.muted })}>{k}</span>
                  <span style={mono({ fontSize:11, color:C.text })}>{v}</span>
                </div>
              ))}
            </div>

            <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
              <button style={s({ background:C.primary, color:"#000", border:"none", borderRadius:8,
                padding:"8px", fontSize:13, fontWeight:700, width:"100%" })}>
                🎤 Schedule Interview
              </button>
              <button style={s({ background:`${C.indigo}20`, color:C.indigo, border:`1px solid ${C.indigo}40`,
                borderRadius:8, padding:"8px", fontSize:13, fontWeight:600, width:"100%" })}>
                📄 View Resume
              </button>
              <button style={s({ background:`${C.red}15`, color:C.red, border:`1px solid ${C.red}30`,
                borderRadius:8, padding:"8px", fontSize:13, fontWeight:600, width:"100%" })}>
                ✗ Reject
              </button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: DIVERSITY ANALYTICS
═══════════════════════════════════════════════ */
function DiversityView() {
  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20 }}>
      <div style={{ display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ fontSize:28 }}>📊</div>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>Diversity & Inclusion Hub</div>
          <div style={mono({ fontSize:12, color:C.muted })}>Real-time DEI metrics · Percentile breakdowns · Sector benchmarking</div>
        </div>
      </div>

      {/* Top KPIs */}
      <div style={{ display:"flex", gap:14 }}>
        {[
          { label:"Diversity Score",   value:"82%",  color:C.primary,  icon:"🏆" },
          { label:"Female Applicants", value:"44%",  color:C.pink,     icon:"♀️" },
          { label:"PWD Included",      value:"9%",   color:C.amber,    icon:"♿" },
          { label:"Bias Flags Raised", value:"3",    color:C.red,      icon:"🚨" },
        ].map((k,i)=><KpiCard key={i} {...k}/>)}
      </div>

      <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16 }}>
        {/* Gender Pie */}
        <Card>
          <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>Gender Distribution</div>
          <ResponsiveContainer width="100%" height={160}>
            <PieChart>
              <Pie data={DIVERSITY_DATA.gender} cx="50%" cy="50%" innerRadius={45} outerRadius={70}
                dataKey="value" paddingAngle={4}>
                {DIVERSITY_DATA.gender.map((e,i)=><Cell key={i} fill={e.color}/>)}
              </Pie>
              <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}/>
            </PieChart>
          </ResponsiveContainer>
          <div style={{ display:"flex", justifyContent:"center", gap:16 }}>
            {DIVERSITY_DATA.gender.map((g,i)=>(
              <div key={i} style={{ display:"flex", alignItems:"center", gap:6 }}>
                <div style={{ width:10, height:10, borderRadius:"50%", background:g.color }}/>
                <span style={mono({ fontSize:11, color:C.muted })}>{g.name} {g.value}%</span>
              </div>
            ))}
          </div>
        </Card>

        {/* Age Distribution */}
        <Card>
          <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>Age Distribution</div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={DIVERSITY_DATA.age} barSize={28}>
              <XAxis dataKey="range" tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
              <YAxis tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
              <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}
                itemStyle={{ color:C.primary }}/>
              <Bar dataKey="count" fill={C.indigo} radius={[6,6,0,0]}/>
            </BarChart>
          </ResponsiveContainer>
        </Card>

        {/* Sector Diversity */}
        <Card style={{ gridColumn:"span 2" }}>
          <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>Gender Diversity by Sector (%)</div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={DIVERSITY_DATA.sectorDiv} barGap={4}>
              <XAxis dataKey="sector" tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
              <YAxis tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
              <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}/>
              <Bar dataKey="female" name="Female" fill={C.pink} radius={[4,4,0,0]} stackId={undefined}/>
              <Bar dataKey="male" name="Male" fill={C.indigo} radius={[4,4,0,0]}/>
              <Bar dataKey="other" name="Other" fill={C.amber} radius={[4,4,0,0]}/>
            </BarChart>
          </ResponsiveContainer>
        </Card>
      </div>

      {/* Percentile Breakdown Table */}
      <Card>
        <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>📋 Candidate Percentile Breakdown</div>
        <table style={{ width:"100%", borderCollapse:"collapse" }}>
          <thead>
            <tr style={{ borderBottom:`1px solid ${C.border}` }}>
              {["Group","Total Applicants","Avg Score","Shortlisted","Selection Rate","Percentile"].map(h=>(
                <th key={h} style={mono({ textAlign:"left", fontSize:10, color:C.muted, padding:"8px 12px", letterSpacing:"0.05em" })}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {[
              { group:"Women",             icon:"♀️", total:109, avg:83, shortlisted:3, rate:"2.8%", pct:82 },
              { group:"Men",               icon:"♂️", total:129, avg:81, shortlisted:4, rate:"3.1%", pct:79 },
              { group:"Under 30",          icon:"🌱", total:87,  avg:85, shortlisted:4, rate:"4.6%", pct:88 },
              { group:"30–45",             icon:"💼", total:118, avg:82, shortlisted:3, rate:"2.5%", pct:77 },
              { group:"45+",               icon:"🧓", total:43,  avg:76, shortlisted:0, rate:"0%",   pct:52 },
              { group:"Persons w/ Disab.", icon:"♿", total:22,  avg:80, shortlisted:2, rate:"9.1%", pct:85 },
            ].map((row,i)=>(
              <tr key={i} style={{ borderBottom:`1px solid ${C.border}30` }}>
                <td style={{ padding:"10px 12px" }}>
                  <span style={{ marginRight:8 }}>{row.icon}</span>
                  <span style={s({ fontSize:13, color:C.text })}>{row.group}</span>
                </td>
                <td style={mono({ padding:"10px 12px", fontSize:13, color:C.muted })}>{row.total}</td>
                <td style={mono({ padding:"10px 12px", fontSize:13, color:C.text })}>{row.avg}</td>
                <td style={mono({ padding:"10px 12px", fontSize:13, color:C.text })}>{row.shortlisted}</td>
                <td style={{ padding:"10px 12px" }}>
                  <Badge color={parseFloat(row.rate)>3?C.green:parseFloat(row.rate)>0?C.amber:C.red}>{row.rate}</Badge>
                </td>
                <td style={{ padding:"10px 12px" }}>
                  <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                    <div style={{ flex:1, height:6, background:C.border, borderRadius:3 }}>
                      <div style={{ height:"100%", width:`${row.pct}%`, borderRadius:3,
                        background: row.pct>=80?C.primary:row.pct>=60?C.amber:C.red }}/>
                    </div>
                    <span style={mono({ fontSize:11, color:C.muted })}>{row.pct}th</span>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: COMPANY INSIGHTS
═══════════════════════════════════════════════ */
function CompanyInsightsView() {
  const [selected, setSelected] = useState(COMPANIES[0]);
  const [tab, setTab] = useState("overview");

  const salaryData = [
    { role:"Junior", min:8, max:14 }, { role:"Mid-level", min:14, max:24 },
    { role:"Senior", min:24, max:40 }, { role:"Lead", min:38, max:60 }, { role:"Manager", min:50, max:90 },
  ];

  const reviews = [
    { text:"Great work-life balance and inclusive culture. Management actually listens.", rating:5, anonymous:true, date:"Feb 2026" },
    { text:"Salary could be better but the learning opportunities are fantastic.", rating:4, anonymous:true, date:"Jan 2026" },
    { text:"DEI initiatives are real, not just on paper. Women in leadership is strong.", rating:5, anonymous:false, date:"Jan 2026" },
    { text:"Limited growth path for senior engineers without switching to management.", rating:3, anonymous:true, date:"Dec 2025" },
  ];

  return (
    <div className="fadeUp" style={{ display:"flex", gap:20 }}>
      {/* Company List */}
      <div style={{ width:220, flexShrink:0 }}>
        <div style={s({ fontSize:13, fontWeight:700, color:C.muted, marginBottom:12 })}>COMPANIES</div>
        {COMPANIES.map(co=>(
          <div key={co.name} onClick={()=>setSelected(co)} className="card-link"
            style={{ padding:"10px 12px", borderRadius:10, marginBottom:8, cursor:"pointer",
              background: selected?.name===co.name ? C.cardHover : C.card,
              border:`1px solid ${selected?.name===co.name ? C.primary+"50" : C.border}` }}>
            <div style={s({ fontSize:13, fontWeight:700, color:C.text })}>{co.name}</div>
            <div style={mono({ fontSize:11, color:C.muted })}>{co.industry}</div>
            <div style={{ display:"flex", gap:4, marginTop:6 }}>
              <Badge color={co.diversity>=80?C.primary:co.diversity>=60?C.amber:C.red}>
                DEI {co.diversity}
              </Badge>
            </div>
          </div>
        ))}
      </div>

      {/* Company Detail */}
      {selected && (
        <div style={{ flex:1, display:"flex", flexDirection:"column", gap:16 }}>
          {/* Header */}
          <Card style={{ background:`linear-gradient(135deg, ${C.card} 0%, ${C.pDim} 100%)`, borderColor:`${C.primary}30` }}>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"flex-start" }}>
              <div>
                <div style={s({ fontSize:24, fontWeight:800, color:C.text })}>{selected.name}</div>
                <div style={mono({ fontSize:12, color:C.muted, marginTop:4 })}>{selected.industry} · {selected.employees.toLocaleString()} employees</div>
                <div style={{ display:"flex", gap:8, marginTop:10, flexWrap:"wrap" }}>
                  <Badge color={C.amber}>⭐ {selected.rating}/5</Badge>
                  <Badge color={C.muted}>{selected.reviews} reviews</Badge>
                  <Badge color={C.primary}>Avg: {selected.avgSalary}</Badge>
                </div>
              </div>
              <div style={s({ fontSize:36, fontWeight:800, color: selected.diversity>=80?C.primary:selected.diversity>=60?C.amber:C.red })}>
                {selected.diversity}
                <span style={mono({ fontSize:12, color:C.muted })}>/100 DEI</span>
              </div>
            </div>
          </Card>

          {/* Tabs */}
          <div style={{ display:"flex", gap:4 }}>
            {["overview","salary","diversity","reviews"].map(t=>(
              <button key={t} onClick={()=>setTab(t)}
                style={s({ background: tab===t ? C.primary : C.card,
                  color: tab===t ? "#000" : C.muted,
                  border:`1px solid ${tab===t ? C.primary : C.border}`,
                  borderRadius:8, padding:"6px 16px", fontSize:12, fontWeight: tab===t?700:400, cursor:"pointer",
                  textTransform:"capitalize" })}>
                {t}
              </button>
            ))}
          </div>

          {tab==="overview" && (
            <div style={{ display:"flex", flexDirection:"column", gap:12 }}>
              <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:12 }}>
                {[
                  { label:"Female",    value:`${selected.genderRatio.f}%`, color:C.pink   },
                  { label:"Male",      value:`${selected.genderRatio.m}%`, color:C.indigo },
                  { label:"Other",     value:`${selected.genderRatio.o}%`, color:C.amber  },
                  { label:"Total Employees", value:selected.employees.toLocaleString(), color:C.primary },
                  { label:"Avg Salary Range",value:selected.avgSalary, color:C.green },
                  { label:"DEI Score", value:selected.diversity+"/100", color:C.primary },
                ].map((s,i)=>(
                  <Card key={i} style={{ textAlign:"center" }}>
                    <div style={mono({ fontSize:10, color:C.muted, marginBottom:6 })}>{s.label}</div>
                    <div style={{ fontSize:20, fontWeight:800, color:s.color, fontFamily:"'Syne',sans-serif" }}>{s.value}</div>
                  </Card>
                ))}
              </div>
              {/* Tkinter-style employee diversity breakdown row */}
              <Card style={{ borderColor:`${C.primary}20` }}>
                <div style={s({ fontSize:13, fontWeight:700, color:C.text, marginBottom:12 })}>👥 Workforce Breakdown</div>
                <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr 1fr", gap:16 }}>
                  <div>
                    <div style={mono({ fontSize:10, color:C.muted, marginBottom:4 })}>SALARY RANGE</div>
                    <div style={s({ fontSize:15, fontWeight:700, color:C.green })}>{selected.salaryRange}</div>
                  </div>
                  <div>
                    <div style={mono({ fontSize:10, color:C.muted, marginBottom:4 })}>MALE EMPLOYEES</div>
                    <div style={s({ fontSize:15, fontWeight:700, color:C.indigo })}>{selected.maleEmployees.toLocaleString()}</div>
                    <div style={{ height:4, background:C.border, borderRadius:2, marginTop:4 }}>
                      <div style={{ height:"100%", width:`${selected.genderRatio.m}%`, background:C.indigo, borderRadius:2 }}/>
                    </div>
                  </div>
                  <div>
                    <div style={mono({ fontSize:10, color:C.muted, marginBottom:4 })}>FEMALE EMPLOYEES</div>
                    <div style={s({ fontSize:15, fontWeight:700, color:C.pink })}>{selected.femaleEmployees.toLocaleString()}</div>
                    <div style={{ height:4, background:C.border, borderRadius:2, marginTop:4 }}>
                      <div style={{ height:"100%", width:`${selected.genderRatio.f}%`, background:C.pink, borderRadius:2 }}/>
                    </div>
                  </div>
                </div>
              </Card>
            </div>
          )}

          {tab==="salary" && (
            <Card>
              <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>Salary Ranges by Level (₹ Lakhs/yr)</div>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={salaryData} barGap={6}>
                  <XAxis dataKey="role" tick={{ fill:C.muted, fontSize:12 }} axisLine={false} tickLine={false}/>
                  <YAxis tick={{ fill:C.muted, fontSize:11 }} axisLine={false} tickLine={false}/>
                  <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}/>
                  <Bar dataKey="min" name="Min ₹L" fill={C.indigo} radius={[4,4,0,0]}/>
                  <Bar dataKey="max" name="Max ₹L" fill={C.primary} radius={[4,4,0,0]}/>
                </BarChart>
              </ResponsiveContainer>
            </Card>
          )}

          {tab==="diversity" && (
            <Card>
              <div style={s({ fontSize:14, fontWeight:700, color:C.text, marginBottom:16 })}>Diversity Breakdown</div>
              <ResponsiveContainer width="100%" height={160}>
                <PieChart>
                  <Pie data={[
                    { name:"Female", value:selected.genderRatio.f, color:C.pink },
                    { name:"Male",   value:selected.genderRatio.m, color:C.indigo },
                    { name:"Other",  value:selected.genderRatio.o, color:C.amber },
                  ]} cx="50%" cy="50%" innerRadius={40} outerRadius={70} dataKey="value">
                    {[C.pink,C.indigo,C.amber].map((c,i)=><Cell key={i} fill={c}/>)}
                  </Pie>
                  <Tooltip contentStyle={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:8 }}/>
                </PieChart>
              </ResponsiveContainer>
              <div style={mono({ fontSize:12, color:C.muted, marginTop:12, textAlign:"center" })}>
                Industry Benchmark: Female 38% · Male 59% · Other 3%
              </div>
            </Card>
          )}

          {tab==="reviews" && (
            <div style={{ display:"flex", flexDirection:"column", gap:10 }}>
              {reviews.map((r,i)=>(
                <Card key={i}>
                  <div style={{ display:"flex", justifyContent:"space-between", marginBottom:8 }}>
                    <div style={{ display:"flex", gap:2 }}>
                      {[1,2,3,4,5].map(s=>(
                        <span key={s} style={{ fontSize:14, color: s<=r.rating ? C.amber : C.border }}>★</span>
                      ))}
                    </div>
                    <div style={{ display:"flex", gap:8 }}>
                      {r.anonymous && <Badge color={C.muted}>Anonymous</Badge>}
                      <span style={mono({ fontSize:11, color:C.muted })}>{r.date}</span>
                    </div>
                  </div>
                  <div style={mono({ fontSize:13, color:C.text, lineHeight:1.6 })}>{r.text}</div>
                </Card>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: AI INTERVIEW
═══════════════════════════════════════════════ */
function AIInterviewView() {
  const [sector, setSector] = useState("IT/Software");
  const [candidateName, setCandidateName] = useState("");
  const [role, setRole] = useState("");
  const [phase, setPhase] = useState("setup"); // setup | running | done
  const [currentQ, setCurrentQ] = useState(0);
  const [responses, setResponses] = useState([]);
  const [currentResponse, setCurrentResponse] = useState("");
  const [report, setReport] = useState(null);
  const [loading, setLoading] = useState(false);
  const questions = INTERVIEW_QUESTIONS[sector] || [];

  const startInterview = () => {
    if (!candidateName.trim()) return;
    setPhase("running"); setCurrentQ(0); setResponses([]); setCurrentResponse("");
  };

  const submitResponse = () => {
    if (!currentResponse.trim()) return;
    const updated = [...responses, { q: questions[currentQ], a: currentResponse }];
    setResponses(updated);
    setCurrentResponse("");
    if (currentQ + 1 < questions.length) {
      setCurrentQ(currentQ + 1);
    } else {
      generateReport(updated);
    }
  };

  const generateReport = async (allResponses) => {
    setPhase("done"); setLoading(true);
    try {
      const raw = await askClaude(
        `You are an expert, bias-aware interview evaluator. Evaluate candidate responses fairly.
Return ONLY valid JSON (no markdown):
{
  "overall_score": number 0-100,
  "recommendation": "Strong Recommend" | "Recommend" | "Consider" | "Do Not Recommend",
  "category_scores": {"technical_skills": number, "communication": number, "problem_solving": number, "cultural_fit": number, "experience_relevance": number},
  "bias_flags": [{"question": string, "concern": string}],
  "strengths": [string],
  "areas_for_improvement": [string],
  "bias_mitigation_notes": string,
  "next_steps": [string]
}`,
        `Candidate: ${candidateName}\nRole: ${role || sector}\nSector: ${sector}\n\nQ&A:\n${allResponses.map((r,i)=>`Q${i+1}: ${r.q}\nA: ${r.a}`).join("\n\n")}`
      );
      const clean = raw.replace(/```json|```/g,"").trim();
      setReport(JSON.parse(clean));
    } catch { setReport({ error:"Report generation failed." }); }
    setLoading(false);
  };

  const recColor = { "Strong Recommend":C.green, "Recommend":C.primary, "Consider":C.amber, "Do Not Recommend":C.red };

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20 }}>
      <div style={{ display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ fontSize:28 }}>🎤</div>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>AI Interview System</div>
          <div style={mono({ fontSize:12, color:C.muted })}>Bias-monitored · Standardized questions · Auto-evaluated</div>
        </div>
      </div>

      {phase==="setup" && (
        <Card>
          <div style={s({ fontSize:16, fontWeight:700, color:C.text, marginBottom:20 })}>Setup Interview Session</div>
          <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16, marginBottom:16 }}>
            <div>
              <div style={mono({ fontSize:11, color:C.muted, marginBottom:6 })}>CANDIDATE NAME</div>
              <input value={candidateName} onChange={e=>setCandidateName(e.target.value)}
                placeholder="e.g. Priya Sharma"
                style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                  borderRadius:8, padding:"10px 12px", color:C.text, fontSize:13 })}/>
            </div>
            <div>
              <div style={mono({ fontSize:11, color:C.muted, marginBottom:6 })}>ROLE</div>
              <input value={role} onChange={e=>setRole(e.target.value)}
                placeholder="e.g. Senior Software Engineer"
                style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                  borderRadius:8, padding:"10px 12px", color:C.text, fontSize:13 })}/>
            </div>
          </div>
          <div style={{ marginBottom:20 }}>
            <div style={mono({ fontSize:11, color:C.muted, marginBottom:6 })}>SECTOR</div>
            <div style={{ display:"flex", gap:8, flexWrap:"wrap" }}>
              {Object.keys(INTERVIEW_QUESTIONS).map(sec=>(
                <button key={sec} onClick={()=>setSector(sec)}
                  style={s({ background: sector===sec ? C.primary : C.surface,
                    color: sector===sec ? "#000" : C.muted,
                    border:`1px solid ${sector===sec ? C.primary : C.border}`,
                    borderRadius:8, padding:"6px 14px", fontSize:12, fontWeight: sector===sec?700:400 })}>
                  {sec}
                </button>
              ))}
            </div>
          </div>
          <div style={{ background:C.surface, borderRadius:10, padding:"1rem", marginBottom:20 }}>
            <div style={mono({ fontSize:11, color:C.muted, marginBottom:10 })}>PREVIEW QUESTIONS ({questions.length})</div>
            {questions.map((q,i)=>(
              <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                <span style={{ color:C.primary }}>Q{i+1}.</span> {q}
              </div>
            ))}
          </div>
          <button onClick={startInterview} disabled={!candidateName.trim()} className="glow-btn"
            style={s({ background:C.primary, color:"#000", border:"none", borderRadius:10,
              padding:"12px 32px", fontSize:14, fontWeight:700, opacity:!candidateName.trim()?0.5:1 })}>
            🎤 Begin Interview
          </button>
        </Card>
      )}

      {phase==="running" && (
        <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
          {/* Progress */}
          <Card style={{ padding:"1rem" }}>
            <div style={{ display:"flex", justifyContent:"space-between", marginBottom:8 }}>
              <span style={mono({ fontSize:12, color:C.muted })}>Question {currentQ+1} of {questions.length}</span>
              <span style={mono({ fontSize:12, color:C.primary })}>{candidateName} · {sector}</span>
            </div>
            <div style={{ height:4, background:C.border, borderRadius:2 }}>
              <div style={{ height:"100%", width:`${((currentQ)/questions.length)*100}%`,
                background:C.primary, borderRadius:2, transition:"width 0.4s ease" }}/>
            </div>
          </Card>

          {/* Current Question */}
          <Card style={{ borderColor:`${C.primary}30`, background:`${C.pDim}` }}>
            <div style={mono({ fontSize:11, color:C.primary, marginBottom:8 })}>QUESTION {currentQ+1}</div>
            <div style={s({ fontSize:18, fontWeight:700, color:C.text, lineHeight:1.5 })}>
              {questions[currentQ]}
            </div>
          </Card>

          {/* Previous Answers */}
          {responses.length > 0 && (
            <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
              {responses.map((r,i)=>(
                <div key={i} style={{ padding:"10px 14px", background:C.surface,
                  borderLeft:`3px solid ${C.indigo}40`, borderRadius:"0 8px 8px 0" }}>
                  <div style={mono({ fontSize:11, color:C.indigo, marginBottom:4 })}>Q{i+1}: {r.q}</div>
                  <div style={mono({ fontSize:12, color:C.muted })}>{r.a}</div>
                </div>
              ))}
            </div>
          )}

          {/* Response Input */}
          <Card>
            <div style={mono({ fontSize:11, color:C.muted, marginBottom:8 })}>CANDIDATE RESPONSE</div>
            <textarea value={currentResponse} onChange={e=>setCurrentResponse(e.target.value)}
              placeholder="Type or paste the candidate's response here..."
              style={mono({ width:"100%", minHeight:120, background:C.surface, border:`1px solid ${C.border}`,
                borderRadius:10, padding:"12px", color:C.text, fontSize:13, resize:"vertical", lineHeight:1.6 })}/>
            <div style={{ display:"flex", justifyContent:"flex-end", marginTop:10 }}>
              <button onClick={submitResponse} disabled={!currentResponse.trim()}
                style={s({ background:C.primary, color:"#000", border:"none", borderRadius:8,
                  padding:"10px 24px", fontSize:13, fontWeight:700, opacity:!currentResponse.trim()?0.5:1 })}>
                {currentQ+1 < questions.length ? "Next Question →" : "🏁 Finish & Generate Report"}
              </button>
            </div>
          </Card>
        </div>
      )}

      {phase==="done" && (
        <div style={{ display:"flex", flexDirection:"column", gap:16 }}>
          {loading && <Loader/>}
          {report && !report.error && (
            <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:16 }}>
              <Card style={{ background:`${recColor[report.recommendation]||C.primary}10`, borderColor:`${recColor[report.recommendation]||C.primary}30` }}>
                <div style={{ display:"flex", alignItems:"center", gap:20 }}>
                  <ScoreRing score={report.overall_score} size={90} stroke={7}/>
                  <div>
                    <div style={s({ fontSize:20, fontWeight:800, color:recColor[report.recommendation]||C.primary })}>
                      {report.recommendation}
                    </div>
                    <div style={mono({ fontSize:12, color:C.muted, marginTop:4 })}>
                      {candidateName} · {role||sector} · {questions.length} questions evaluated
                    </div>
                    <div style={mono({ fontSize:11, color:C.muted, marginTop:8, lineHeight:1.5 })}>
                      Bias mitigation: {report.bias_mitigation_notes}
                    </div>
                  </div>
                </div>
              </Card>

              <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:16 }}>
                <Card>
                  <div style={s({ fontSize:13, fontWeight:700, color:C.green, marginBottom:10 })}>💪 Strengths</div>
                  {report.strengths?.map((s,i)=>(
                    <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                      <span style={{ color:C.green }}>▸ </span>{s}
                    </div>
                  ))}
                </Card>
                <Card>
                  <div style={s({ fontSize:13, fontWeight:700, color:C.amber, marginBottom:10 })}>📌 Areas to Improve</div>
                  {report.areas_for_improvement?.map((s,i)=>(
                    <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                      <span style={{ color:C.amber }}>▸ </span>{s}
                    </div>
                  ))}
                </Card>
              </div>

              {report.bias_flags?.length > 0 && (
                <Card style={{ borderColor:`${C.red}30` }}>
                  <div style={s({ fontSize:13, fontWeight:700, color:C.red, marginBottom:10 })}>⚠️ Bias Flags</div>
                  {report.bias_flags.map((f,i)=>(
                    <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:8,
                      padding:"8px 10px", background:C.surface, borderRadius:8 })}>
                      <span style={{ color:C.red }}>Q: </span>{f.question}<br/>
                      <span style={{ color:C.amber }}>⚡ </span>{f.concern}
                    </div>
                  ))}
                </Card>
              )}

              <Card>
                <div style={s({ fontSize:13, fontWeight:700, color:C.primary, marginBottom:10 })}>📋 Next Steps</div>
                {report.next_steps?.map((s,i)=>(
                  <div key={i} style={mono({ fontSize:12, color:C.muted, marginBottom:6 })}>
                    <span style={{ color:C.primary }}>→ </span>{s}
                  </div>
                ))}
              </Card>

              <button onClick={()=>{setPhase("setup");setReport(null);setCandidateName("");setRole("");}}
                style={s({ background:C.surface, color:C.muted, border:`1px solid ${C.border}`,
                  borderRadius:8, padding:"10px 24px", fontSize:13, fontWeight:600, alignSelf:"flex-start" })}>
                ← New Interview
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════
   VIEW: LIVE INTERVIEW (WebRTC + Chat)
═══════════════════════════════════════════════ */
function LiveInterviewView({ user }) {
  const videoRef     = useRef(null);
  const streamRef    = useRef(null);
  const [camOn, setCamOn]       = useState(false);
  const [camErr, setCamErr]     = useState("");
  const [messages, setMessages] = useState([
    { id:0, sender:"System", text:"Live interview session started. Welcome!", time:"now", isSystem:true },
  ]);
  const [input, setInput]       = useState("");
  const [recState, setRecState] = useState("idle"); // idle | recording | paused
  const chatBottomRef           = useRef(null);
  const playKey                 = useTypingSound();

  // Auto-scroll chat
  const scrollChat = () => setTimeout(() => chatBottomRef.current?.scrollIntoView({ behavior:"smooth" }), 50);

  const startCam = async () => {
    setCamErr("");
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ video:true, audio:true });
      streamRef.current = stream;
      if (videoRef.current) videoRef.current.srcObject = stream;
      setCamOn(true);
    } catch(e) {
      setCamErr("Camera/mic access denied or unavailable. Please allow permissions and try again.");
    }
  };

  const stopCam = () => {
    streamRef.current?.getTracks().forEach(t => t.stop());
    streamRef.current = null;
    if (videoRef.current) videoRef.current.srcObject = null;
    setCamOn(false);
    setRecState("idle");
  };

  const sendMessage = () => {
    if (!input.trim()) return;
    SoundSystem.playNotify();
    const msg = { id: Date.now(), sender: user?.name || "You", text: input.trim(), time: new Date().toLocaleTimeString([], {hour:"2-digit",minute:"2-digit"}), isSystem:false };
    setMessages(prev => [...prev, msg]);
    setInput("");
    scrollChat();
    // Simulate AI interviewer reply
    setTimeout(() => {
      const replies = [
        "That's a great point. Could you elaborate on the technical approach?",
        "Interesting. How did you handle stakeholder communication in that scenario?",
        "Thanks for sharing. What was the outcome and what did you learn?",
        "Can you walk me through your decision-making process there?",
        "How would you approach that differently today?",
      ];
      const reply = { id: Date.now()+1, sender:"AI Interviewer", text: replies[Math.floor(Math.random()*replies.length)], time: new Date().toLocaleTimeString([], {hour:"2-digit",minute:"2-digit"}), isSystem:false, isAI:true };
      setMessages(prev => [...prev, reply]);
      scrollChat();
    }, 1200 + Math.random()*800);
  };

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20, height:"100%" }}>
      <div style={{ display:"flex", alignItems:"center", gap:12 }}>
        <div style={{ fontSize:28 }}>📹</div>
        <div>
          <div style={s({ fontSize:22, fontWeight:800, color:C.text })}>Live Interview Room</div>
          <div style={mono({ fontSize:12, color:C.muted })}>Webcam · Live chat · AI interviewer</div>
        </div>
      </div>

      <div style={{ display:"grid", gridTemplateColumns:"1fr 360px", gap:16, flex:1, minHeight:0 }}>

        {/* ── LEFT: Video Panel ── */}
        <div style={{ display:"flex", flexDirection:"column", gap:12 }}>
          <Card style={{ padding:0, overflow:"hidden", position:"relative", aspectRatio:"16/9", background:"#000" }}>
            <video ref={videoRef} autoPlay playsInline muted
              style={{ width:"100%", height:"100%", objectFit:"cover", display: camOn?"block":"none" }}/>
            {!camOn && (
              <div style={{ position:"absolute", inset:0, display:"flex", flexDirection:"column",
                alignItems:"center", justifyContent:"center", gap:12,
                background:`linear-gradient(135deg,${C.card},${C.surface})` }}>
                <div style={{ fontSize:56, opacity:0.3 }}>📹</div>
                <div style={mono({ fontSize:13, color:C.muted })}>Camera is off</div>
                {camErr && <div style={mono({ fontSize:11, color:C.red, textAlign:"center", maxWidth:260, padding:"0 1rem" })}>{camErr}</div>}
              </div>
            )}
            {/* Recording badge */}
            {recState==="recording" && (
              <div style={{ position:"absolute", top:12, left:12, display:"flex", alignItems:"center", gap:6,
                background:"rgba(0,0,0,0.7)", borderRadius:20, padding:"4px 12px",
                border:`1px solid ${C.red}60` }}>
                <div style={{ width:8, height:8, borderRadius:"50%", background:C.red }} className="pulse"/>
                <span style={mono({ fontSize:11, color:C.red })}>REC</span>
              </div>
            )}
            {/* Live badge */}
            {camOn && (
              <div style={{ position:"absolute", top:12, right:12, display:"flex", alignItems:"center", gap:6,
                background:"rgba(0,0,0,0.7)", borderRadius:20, padding:"4px 12px",
                border:`1px solid ${C.green}60` }}>
                <div style={{ width:8, height:8, borderRadius:"50%", background:C.green }} className="pulse"/>
                <span style={mono({ fontSize:11, color:C.green })}>LIVE</span>
              </div>
            )}
          </Card>

          {/* Controls */}
          <div style={{ display:"flex", gap:10, flexWrap:"wrap" }}>
            {!camOn ? (
              <button onClick={startCam} className="glow-btn"
                style={s({ background:C.primary, color:"#000", border:"none", borderRadius:10,
                  padding:"10px 24px", fontSize:13, fontWeight:700 })}>
                📹 Start Camera
              </button>
            ) : (
              <button onClick={stopCam}
                style={s({ background:`${C.red}15`, color:C.red, border:`1px solid ${C.red}40`,
                  borderRadius:10, padding:"10px 24px", fontSize:13, fontWeight:700 })}>
                ⏹ Stop Camera
              </button>
            )}
            <button
              onClick={()=>setRecState(r => r==="idle"?"recording": r==="recording"?"paused":"recording")}
              disabled={!camOn}
              style={s({ background: recState==="recording"?`${C.amber}15`:`${C.indigo}15`,
                color: recState==="recording"?C.amber:C.indigo,
                border:`1px solid ${recState==="recording"?C.amber:C.indigo}40`,
                borderRadius:10, padding:"10px 20px", fontSize:13, fontWeight:700,
                opacity: camOn?1:0.4 })}>
              {recState==="recording"?"⏸ Pause Rec": recState==="paused"?"▶ Resume":"⏺ Record"}
            </button>
            <button onClick={()=>{ SoundSystem.playNotify(); setMessages(prev=>[...prev,
              {id:Date.now(),sender:"System",text:"Screen sharing is not supported in this environment.",time:"now",isSystem:true}]);
              scrollChat(); }}
              style={s({ background:`${C.primary}12`, color:C.primary, border:`1px solid ${C.primary}30`,
                borderRadius:10, padding:"10px 20px", fontSize:13, fontWeight:700 })}>
              🖥 Share Screen
            </button>
          </div>

          {/* Interview info card */}
          <Card style={{ padding:"1rem" }}>
            <div style={{ display:"flex", gap:16, flexWrap:"wrap" }}>
              {[
                {label:"Session ID",  value:"#IQ-2024-"+String(user?.name||"").slice(0,3).toUpperCase()+"-001", color:C.muted},
                {label:"Duration",    value:"Live",    color:C.green},
                {label:"Interviewer", value:"AI System", color:C.indigo},
                {label:"Mode",        value:"Video + Chat", color:C.primary},
              ].map((it,i)=>(
                <div key={i}>
                  <div style={mono({ fontSize:10, color:C.muted })}>{it.label}</div>
                  <div style={mono({ fontSize:12, color:it.color, fontWeight:500, marginTop:2 })}>{it.value}</div>
                </div>
              ))}
            </div>
          </Card>
        </div>

        {/* ── RIGHT: Chat Panel ── */}
        <Card style={{ display:"flex", flexDirection:"column", gap:0, padding:0, overflow:"hidden", height:"calc(100vh - 260px)", minHeight:400 }}>
          {/* Chat header */}
          <div style={{ padding:"12px 16px", borderBottom:`1px solid ${C.border}`,
            display:"flex", alignItems:"center", justifyContent:"space-between", flexShrink:0 }}>
            <div style={s({ fontSize:13, fontWeight:700, color:C.text })}>💬 Live Chat</div>
            <Badge color={C.green}>{messages.length} msgs</Badge>
          </div>

          {/* Messages */}
          <div style={{ flex:1, overflowY:"auto", padding:"12px 16px", display:"flex", flexDirection:"column", gap:10 }}>
            {messages.map(msg=>(
              <div key={msg.id} style={{ display:"flex", flexDirection:"column",
                alignItems: msg.isSystem?"center": msg.isAI?"flex-start":"flex-end" }}>
                {msg.isSystem ? (
                  <div style={mono({ fontSize:10, color:C.muted, background:C.surface, borderRadius:8,
                    padding:"4px 10px", border:`1px solid ${C.border}` })}>{msg.text}</div>
                ) : (
                  <div style={{ maxWidth:"85%" }}>
                    <div style={mono({ fontSize:10, color: msg.isAI?C.indigo:C.muted, marginBottom:3,
                      textAlign: msg.isAI?"left":"right" })}>
                      {msg.isAI?"🤖 ":""}{msg.sender} · {msg.time}
                    </div>
                    <div style={{ background: msg.isAI ? `${C.indigo}15` : `${C.primary}15`,
                      border:`1px solid ${msg.isAI ? C.indigo+"30" : C.primary+"30"}`,
                      borderRadius:12, padding:"8px 12px" }}>
                      <div style={mono({ fontSize:12, color:C.text, lineHeight:1.5 })}>{msg.text}</div>
                    </div>
                  </div>
                )}
              </div>
            ))}
            <div ref={chatBottomRef}/>
          </div>

          {/* Input */}
          <div style={{ padding:"12px 16px", borderTop:`1px solid ${C.border}`, display:"flex", gap:8, flexShrink:0 }}>
            <input value={input} onChange={e=>{setInput(e.target.value);playKey();}}
              onKeyDown={e=>e.key==="Enter"&&!e.shiftKey&&sendMessage()}
              placeholder="Type a message..."
              style={mono({ flex:1, background:C.surface, border:`1px solid ${C.border}`,
                borderRadius:8, padding:"8px 12px", color:C.text, fontSize:12 })}/>
            <button onClick={sendMessage} disabled={!input.trim()}
              style={s({ background:C.primary, color:"#000", border:"none", borderRadius:8,
                padding:"8px 14px", fontSize:12, fontWeight:700, opacity:input.trim()?1:0.4 })}>
              Send
            </button>
          </div>
        </Card>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   AUTH CONFIG
═══════════════════════════════════════════════ */
const DEMO_USERS = [
  { email:"admin@hireiq.com",    password:"admin123",   role:"Admin",    name:"Arjun Mehta",     sector:"All" },
  { email:"manager@hireiq.com",  password:"manager123", role:"Manager",  name:"Priya Desai",     sector:"IT/Software" },
  { email:"hr@hireiq.com",       password:"hr123",      role:"HR",       name:"Sunita Rao",      sector:"All" },
  { email:"employee@hireiq.com", password:"emp123",     role:"Employee", name:"Rahul Verma",     sector:"Pharma" },
];

const ROLE_CONFIG = {
  Admin:    { color:C.red,     icon:"🛡️",  label:"Admin",    navIds:["dashboard","jd-scanner","resume","tests","candidates","diversity","insights","interview","live-interview","settings"] },
  Manager:  { color:C.amber,   icon:"💼",  label:"Manager",  navIds:["dashboard","candidates","tests","diversity","interview","live-interview","insights","settings"] },
  HR:       { color:C.indigo,  icon:"👤",  label:"HR",       navIds:["dashboard","jd-scanner","resume","tests","candidates","diversity","live-interview","settings"] },
  Employee: { color:C.primary, icon:"🙋",  label:"Employee", navIds:["dashboard","resume","insights","live-interview","settings"] },
};

/* ═══════════════════════════════════════════════
   LOGIN SCREEN
═══════════════════════════════════════════════ */
/* ═══════════════════════════════════════════════
   GLOBAL SOUND SYSTEM (pygame → Web Audio API)
   Volume: 0.0–1.0, controllable from Settings
═══════════════════════════════════════════════ */
const SoundSystem = {
  _ctx: null,
  volume: 0.5,   // default 50%
  enabled: true,
  _getCtx() {
    if (!this._ctx) this._ctx = new (window.AudioContext || window.webkitAudioContext)();
    return this._ctx;
  },
  playTap() {
    if (!this.enabled || this.volume === 0) return;
    try {
      const ctx = this._getCtx();
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.connect(gain); gain.connect(ctx.destination);
      osc.type = "square";
      osc.frequency.setValueAtTime(600 + Math.random()*200, ctx.currentTime);
      osc.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + 0.04);
      gain.gain.setValueAtTime(this.volume * 0.08, ctx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.05);
      osc.start(ctx.currentTime); osc.stop(ctx.currentTime + 0.06);
    } catch {}
  },
  playNotify() {
    if (!this.enabled || this.volume === 0) return;
    try {
      const ctx = this._getCtx();
      [0, 0.08, 0.16].forEach(delay => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.connect(gain); gain.connect(ctx.destination);
        osc.type = "sine";
        osc.frequency.setValueAtTime(880, ctx.currentTime + delay);
        gain.gain.setValueAtTime(this.volume * 0.12, ctx.currentTime + delay);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + delay + 0.07);
        osc.start(ctx.currentTime + delay); osc.stop(ctx.currentTime + delay + 0.08);
      });
    } catch {}
  },
};

function useTypingSound() {
  return useCallback(() => SoundSystem.playTap(), []);
}

function LoginView({ onLogin }) {
  const [authTab, setAuthTab]   = useState("login"); // "login" | "signup" | "forgot"
  const [email, setEmail]       = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole]         = useState("HR");
  const [error, setError]       = useState("");
  const [loading, setLoading]   = useState(false);
  const [showPass, setShowPass] = useState(false);
  // Signup fields
  const [signupName, setSignupName]     = useState("");
  const [signupEmail, setSignupEmail]   = useState("");
  const [signupPass, setSignupPass]     = useState("");
  const [signupRole, setSignupRole]     = useState("HR");
  const [signupMsg, setSignupMsg]       = useState("");
  // Forgot password
  const [forgotEmail, setForgotEmail]   = useState("");
  const [forgotMsg, setForgotMsg]       = useState("");
  // User registry (in-memory, seeded from DEMO_USERS)
  const [users, setUsers] = useState([...DEMO_USERS]);

  const playKey = useTypingSound();

  const handleLogin = async () => {
    setError(""); setLoading(true);
    await new Promise(r => setTimeout(r, 900));
    const user = users.find(u =>
      u.email === email.trim().toLowerCase() &&
      u.password === password &&
      u.role === role
    );
    if (user) { onLogin(user); }
    else { setError("Invalid credentials or role mismatch. Check the demo accounts below."); }
    setLoading(false);
  };

  const handleSignup = async () => {
    if (!signupName || !signupEmail || !signupPass) { setSignupMsg("All fields required."); return; }
    if (users.find(u => u.email === signupEmail.trim().toLowerCase() && u.role === signupRole)) {
      setSignupMsg("Account already exists for this email & role."); return;
    }
    setLoading(true);
    await new Promise(r => setTimeout(r, 700));
    const newUser = { email: signupEmail.trim().toLowerCase(), password: signupPass, role: signupRole, name: signupName, sector: "All" };
    setUsers(prev => [...prev, newUser]);
    setSignupMsg(""); setLoading(false);
    onLogin(newUser);
  };

  const handleForgotPassword = async () => {
    if (!forgotEmail) { setForgotMsg("Please enter your email."); return; }
    setLoading(true);
    await new Promise(r => setTimeout(r, 700));
    const found = users.find(u => u.email === forgotEmail.trim().toLowerCase());
    setForgotMsg(found
      ? `✅ Password reset link sent to ${forgotEmail}`
      : "❌ Email not found. Please check and try again."
    );
    setLoading(false);
  };

  const quickFill = (u) => { setEmail(u.email); setPassword(u.password); setRole(u.role); setError(""); };

  return (
    <div style={{ minHeight:"100vh", background:C.bg, display:"flex", alignItems:"center",
      justifyContent:"center", fontFamily:"'Syne',sans-serif", padding:"2rem",
      backgroundImage:`radial-gradient(ellipse at 20% 50%, ${C.pDim} 0%, transparent 60%),
                       radial-gradient(ellipse at 80% 20%, ${C.indigo}10 0%, transparent 50%)` }}>
      <div style={{ width:"100%", maxWidth:900, display:"grid", gridTemplateColumns:"1fr 1fr", gap:32,
        alignItems:"center" }}>

        {/* Left: Branding */}
        <div className="fadeUp">
          <div style={s({ fontSize:48, fontWeight:800, color:C.primary, letterSpacing:"-0.03em", lineHeight:1 })}>
            HireIQ
          </div>
          <div style={mono({ fontSize:13, color:C.muted, letterSpacing:"0.1em", marginBottom:32 })}>
            BIAS-AWARE HIRING INTELLIGENCE
          </div>
          <div style={{ display:"flex", flexDirection:"column", gap:14 }}>
            {[
              { icon:"🔍", text:"AI-powered JD bias detection" },
              { icon:"📄", text:"Resume scoring across 5 dimensions" },
              { icon:"⚡", text:"3-level skill assessment gating" },
              { icon:"📊", text:"Real-time DEI analytics & percentiles" },
              { icon:"🎤", text:"Automated AI interview pipeline" },
              { icon:"🏢", text:"Company insights & benchmarking" },
            ].map((f,i)=>(
              <div key={i} style={{ display:"flex", alignItems:"center", gap:12,
                animation:`fadeUp 0.4s ease ${i*0.06}s both` }}>
                <div style={{ width:36, height:36, borderRadius:10, background:`${C.primary}12`,
                  border:`1px solid ${C.primary}25`, display:"flex", alignItems:"center",
                  justifyContent:"center", fontSize:16, flexShrink:0 }}>{f.icon}</div>
                <span style={mono({ fontSize:12, color:C.muted })}>{f.text}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Right: Auth Form */}
        <div className="fadeUp" style={{ animationDelay:"0.1s" }}>
          <div style={{ background:C.card, border:`1px solid ${C.border}`, borderRadius:20, padding:"2rem" }}>

            {/* Auth Tabs */}
            <div style={{ display:"flex", gap:4, marginBottom:20, background:C.surface,
              borderRadius:12, padding:4 }}>
              {[{id:"login",label:"Sign In"},{id:"signup",label:"Sign Up"},{id:"forgot",label:"Forgot Password"}].map(t=>(
                <button key={t.id} onClick={()=>{setAuthTab(t.id);setError("");setSignupMsg("");setForgotMsg("");}}
                  style={s({ flex:1, padding:"7px 8px", borderRadius:9, border:"none", cursor:"pointer",
                    background: authTab===t.id ? C.primary : "transparent",
                    color: authTab===t.id ? "#000" : C.muted,
                    fontSize:12, fontWeight: authTab===t.id?700:400, transition:"all 0.15s" })}>
                  {t.label}
                </button>
              ))}
            </div>

            {/* ── LOGIN TAB ── */}
            {authTab==="login" && (<>
              <div style={s({ fontSize:20, fontWeight:800, color:C.text, marginBottom:4 })}>Welcome back</div>
              <div style={mono({ fontSize:12, color:C.muted, marginBottom:20 })}>Sign in to your HireIQ account</div>

              <div style={{ marginBottom:16 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:8, letterSpacing:"0.08em" })}>SELECT ROLE</div>
                <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:8 }}>
                  {["HR","Admin","Manager","Employee"].map(r => {
                    const rc = ROLE_CONFIG[r];
                    return (
                      <button key={r} onClick={()=>setRole(r)}
                        style={{ padding:"8px 10px", borderRadius:10, border:`1px solid ${role===r ? rc.color+"60" : C.border}`,
                          background: role===r ? `${rc.color}15` : C.surface, cursor:"pointer",
                          display:"flex", alignItems:"center", gap:8, transition:"all 0.15s" }}>
                        <span style={{ fontSize:14 }}>{rc.icon}</span>
                        <span style={s({ fontSize:12, color: role===r ? rc.color : C.muted, fontWeight: role===r?700:400 })}>{r}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              <div style={{ marginBottom:12 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>EMAIL</div>
                <input value={email} onChange={e=>{setEmail(e.target.value);playKey();}}
                  placeholder="your@email.com" type="email"
                  style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                    borderRadius:10, padding:"10px 14px", color:C.text, fontSize:13 })}/>
              </div>

              <div style={{ marginBottom:20 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>PASSWORD</div>
                <div style={{ position:"relative" }}>
                  <input value={password} onChange={e=>{setPassword(e.target.value);playKey();}}
                    placeholder="••••••••" type={showPass?"text":"password"}
                    onKeyDown={e=>e.key==="Enter"&&handleLogin()}
                    style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                      borderRadius:10, padding:"10px 40px 10px 14px", color:C.text, fontSize:13 })}/>
                  <button onClick={()=>setShowPass(!showPass)}
                    style={{ position:"absolute", right:12, top:"50%", transform:"translateY(-50%)",
                      background:"none", border:"none", color:C.muted, fontSize:14, cursor:"pointer" }}>
                    {showPass?"🙈":"👁️"}
                  </button>
                </div>
                <button onClick={()=>{setAuthTab("forgot");setForgotEmail(email);}}
                  style={{ background:"none", border:"none", color:C.muted, fontSize:11,
                    cursor:"pointer", marginTop:6, padding:0, fontFamily:"'DM Mono',monospace" }}>
                  Forgot password?
                </button>
              </div>

              {error && (
                <div style={{ background:`${C.red}12`, border:`1px solid ${C.red}30`, borderRadius:8,
                  padding:"8px 12px", marginBottom:14 }}>
                  <span style={mono({ fontSize:11, color:C.red })}>{error}</span>
                </div>
              )}

              <button onClick={handleLogin} disabled={loading || !email || !password} className="glow-btn"
                style={s({ width:"100%", background: C.primary, color:"#000", border:"none",
                  borderRadius:10, padding:"12px", fontSize:14, fontWeight:800,
                  opacity:(loading||!email||!password)?0.5:1, marginBottom:20 })}>
                {loading ? "Signing in..." : `Sign in as ${role} →`}
              </button>

              <div style={{ borderTop:`1px solid ${C.border}`, paddingTop:16 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:10, letterSpacing:"0.08em" })}>
                  DEMO ACCOUNTS — click to auto-fill
                </div>
                <div style={{ display:"flex", flexDirection:"column", gap:6 }}>
                  {DEMO_USERS.map((u,i)=>(
                    <button key={i} onClick={()=>quickFill(u)}
                      style={{ display:"flex", justifyContent:"space-between", alignItems:"center",
                        background:C.surface, border:`1px solid ${C.border}`, borderRadius:8,
                        padding:"6px 10px", cursor:"pointer", transition:"all 0.15s" }}>
                      <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                        <span style={{ fontSize:12 }}>{ROLE_CONFIG[u.role].icon}</span>
                        <span style={mono({ fontSize:11, color:C.text })}>{u.email}</span>
                      </div>
                      <Badge color={ROLE_CONFIG[u.role].color}>{u.role}</Badge>
                    </button>
                  ))}
                </div>
              </div>
              <div style={{ textAlign:"center", marginTop:16 }}>
                <span style={mono({ fontSize:11, color:C.muted })}>No account? </span>
                <button onClick={()=>setAuthTab("signup")}
                  style={{ background:"none", border:"none", color:C.primary, fontSize:11, cursor:"pointer",
                    fontFamily:"'DM Mono',monospace", fontWeight:700 }}>Sign up →</button>
              </div>
            </>)}

            {/* ── SIGNUP TAB ── */}
            {authTab==="signup" && (<>
              <div style={s({ fontSize:20, fontWeight:800, color:C.text, marginBottom:4 })}>Create account</div>
              <div style={mono({ fontSize:12, color:C.muted, marginBottom:20 })}>Join HireIQ as a team member</div>

              <div style={{ marginBottom:12 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>FULL NAME</div>
                <input value={signupName} onChange={e=>{setSignupName(e.target.value);playKey();}}
                  placeholder="e.g. Priya Sharma"
                  style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                    borderRadius:10, padding:"10px 14px", color:C.text, fontSize:13 })}/>
              </div>

              <div style={{ marginBottom:12 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>EMAIL</div>
                <input value={signupEmail} onChange={e=>{setSignupEmail(e.target.value);playKey();}}
                  placeholder="your@email.com" type="email"
                  style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                    borderRadius:10, padding:"10px 14px", color:C.text, fontSize:13 })}/>
              </div>

              <div style={{ marginBottom:12 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>PASSWORD</div>
                <input value={signupPass} onChange={e=>{setSignupPass(e.target.value);playKey();}}
                  placeholder="Create a password" type="password"
                  style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                    borderRadius:10, padding:"10px 14px", color:C.text, fontSize:13 })}/>
              </div>

              <div style={{ marginBottom:20 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:8, letterSpacing:"0.08em" })}>ROLE</div>
                <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:8 }}>
                  {["HR","Admin","Manager","Employee"].map(r => {
                    const rc = ROLE_CONFIG[r];
                    return (
                      <button key={r} onClick={()=>setSignupRole(r)}
                        style={{ padding:"8px 10px", borderRadius:10, border:`1px solid ${signupRole===r ? rc.color+"60" : C.border}`,
                          background: signupRole===r ? `${rc.color}15` : C.surface, cursor:"pointer",
                          display:"flex", alignItems:"center", gap:8 }}>
                        <span style={{ fontSize:14 }}>{rc.icon}</span>
                        <span style={s({ fontSize:12, color: signupRole===r ? rc.color : C.muted, fontWeight: signupRole===r?700:400 })}>{r}</span>
                      </button>
                    );
                  })}
                </div>
              </div>

              {signupMsg && (
                <div style={{ background: signupMsg.startsWith("✅") ? `${C.green}12` : `${C.red}12`,
                  border:`1px solid ${signupMsg.startsWith("✅") ? C.green+"30" : C.red+"30"}`,
                  borderRadius:8, padding:"8px 12px", marginBottom:14 }}>
                  <span style={mono({ fontSize:11, color: signupMsg.startsWith("✅") ? C.green : C.red })}>{signupMsg}</span>
                </div>
              )}

              <button onClick={handleSignup} disabled={loading||!signupName||!signupEmail||!signupPass} className="glow-btn"
                style={s({ width:"100%", background:C.primary, color:"#000", border:"none",
                  borderRadius:10, padding:"12px", fontSize:14, fontWeight:800,
                  opacity:(loading||!signupName||!signupEmail||!signupPass)?0.5:1, marginBottom:16 })}>
                {loading ? "Creating account..." : `Create ${signupRole} Account →`}
              </button>
              <div style={{ textAlign:"center" }}>
                <span style={mono({ fontSize:11, color:C.muted })}>Already have an account? </span>
                <button onClick={()=>setAuthTab("login")}
                  style={{ background:"none", border:"none", color:C.primary, fontSize:11, cursor:"pointer",
                    fontFamily:"'DM Mono',monospace", fontWeight:700 }}>Sign in →</button>
              </div>
            </>)}

            {/* ── FORGOT PASSWORD TAB ── */}
            {authTab==="forgot" && (<>
              <div style={s({ fontSize:20, fontWeight:800, color:C.text, marginBottom:4 })}>Reset password</div>
              <div style={mono({ fontSize:12, color:C.muted, marginBottom:20 })}>Enter your email to receive a reset link</div>

              <div style={{ marginBottom:20 }}>
                <div style={mono({ fontSize:10, color:C.muted, marginBottom:6, letterSpacing:"0.08em" })}>EMAIL ADDRESS</div>
                <input value={forgotEmail} onChange={e=>{setForgotEmail(e.target.value);playKey();}}
                  placeholder="your@email.com" type="email"
                  onKeyDown={e=>e.key==="Enter"&&handleForgotPassword()}
                  style={mono({ width:"100%", background:C.surface, border:`1px solid ${C.border}`,
                    borderRadius:10, padding:"10px 14px", color:C.text, fontSize:13 })}/>
              </div>

              {forgotMsg && (
                <div style={{ background: forgotMsg.startsWith("✅") ? `${C.green}12` : `${C.red}12`,
                  border:`1px solid ${forgotMsg.startsWith("✅") ? C.green+"30" : C.red+"30"}`,
                  borderRadius:8, padding:"8px 12px", marginBottom:14 }}>
                  <span style={mono({ fontSize:11, color: forgotMsg.startsWith("✅") ? C.green : C.red })}>{forgotMsg}</span>
                </div>
              )}

              <button onClick={handleForgotPassword} disabled={loading||!forgotEmail} className="glow-btn"
                style={s({ width:"100%", background:C.primary, color:"#000", border:"none",
                  borderRadius:10, padding:"12px", fontSize:14, fontWeight:800,
                  opacity:(loading||!forgotEmail)?0.5:1, marginBottom:16 })}>
                {loading ? "Sending..." : "Send Reset Link →"}
              </button>
              <div style={{ textAlign:"center" }}>
                <button onClick={()=>setAuthTab("login")}
                  style={{ background:"none", border:"none", color:C.muted, fontSize:11, cursor:"pointer",
                    fontFamily:"'DM Mono',monospace" }}>← Back to Sign In</button>
              </div>
            </>)}

          </div>
        </div>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   SETTINGS VIEW
═══════════════════════════════════════════════ */
function SettingsView({ user, onLogout }) {
  const [lang, setLang]           = useState("English");
  const [notifs, setNotifs]       = useState(true);
  const [biasAlerts, setBiasAlerts]= useState(true);
  const [darkMode, setDarkMode]   = useState(true);
  const [saved, setSaved]         = useState(false);
  const [soundEnabled, setSoundEnabled] = useState(SoundSystem.enabled);
  const [soundVolume, setSoundVolume]   = useState(SoundSystem.volume);
  const rc = ROLE_CONFIG[user.role];

  const save = () => {
    SoundSystem.enabled = soundEnabled;
    SoundSystem.volume  = soundVolume;
    SoundSystem.playNotify();
    setSaved(true); setTimeout(()=>setSaved(false), 2000);
  };

  const Toggle = ({ value, onChange, label, desc }) => (
    <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center",
      padding:"12px 0", borderBottom:`1px solid ${C.border}30` }}>
      <div>
        <div style={s({ fontSize:13, fontWeight:600, color:C.text })}>{label}</div>
        {desc && <div style={mono({ fontSize:11, color:C.muted, marginTop:2 })}>{desc}</div>}
      </div>
      <button onClick={()=>onChange(!value)}
        style={{ width:44, height:24, borderRadius:12, border:"none", cursor:"pointer",
          background: value ? C.primary : C.border, position:"relative", transition:"background 0.2s",
          flexShrink:0 }}>
        <div style={{ width:18, height:18, borderRadius:"50%", background:"#fff",
          position:"absolute", top:3, transition:"left 0.2s",
          left: value ? 23 : 3 }}/>
      </button>
    </div>
  );

  return (
    <div className="fadeUp" style={{ display:"flex", flexDirection:"column", gap:20, maxWidth:720 }}>
      {/* Profile Card */}
      <Card style={{ background:`linear-gradient(135deg,${C.card},${C.pDim})`, borderColor:`${rc.color}30` }}>
        <div style={{ display:"flex", alignItems:"center", gap:16 }}>
          <div style={{ width:64, height:64, borderRadius:16, background:`${rc.color}20`,
            border:`2px solid ${rc.color}40`, display:"flex", alignItems:"center",
            justifyContent:"center", fontSize:28, flexShrink:0 }}>{rc.icon}</div>
          <div style={{ flex:1 }}>
            <div style={s({ fontSize:20, fontWeight:800, color:C.text })}>{user.name}</div>
            <div style={mono({ fontSize:12, color:C.muted })}>{user.email}</div>
            <div style={{ display:"flex", gap:8, marginTop:8 }}>
              <Badge color={rc.color}>{user.role}</Badge>
              <Badge color={C.muted}>{user.sector}</Badge>
            </div>
          </div>
          <button style={s({ background:`${C.red}15`, border:`1px solid ${C.red}30`, color:C.red,
            borderRadius:10, padding:"8px 16px", fontSize:13, fontWeight:700 })}>
            ✏️ Edit Profile
          </button>
        </div>
      </Card>

      {/* Manager / Admin Only */}
      {(user.role === "Admin" || user.role === "Manager") && (
        <Card>
          <div style={s({ fontSize:15, fontWeight:800, color:rc.color, marginBottom:16 })}>
            {rc.icon} {user.role} Controls
          </div>
          <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
            {[
              { icon:"👥", label:"Manage Users",   desc:"Add, edit, or deactivate team members",        color:C.indigo  },
              { icon:"⚙️", label:"App Config",      desc:"Configure pipeline stages and scoring weights", color:C.amber   },
              { icon:"📋", label:"Audit Logs",      desc:"View all actions and system events",            color:C.primary },
              ...(user.role==="Admin" ? [
                { icon:"🔑", label:"API Keys",       desc:"Manage Claude AI and integration keys",         color:C.red    },
                { icon:"🏢", label:"Organization",   desc:"Company profile and billing settings",          color:C.green  },
              ] : []),
            ].map((item,i)=>(
              <button key={i} className="card-link"
                style={{ display:"flex", alignItems:"center", gap:12, padding:"12px 14px",
                  background:C.surface, border:`1px solid ${C.border}`, borderRadius:12,
                  textAlign:"left", width:"100%", cursor:"pointer" }}>
                <div style={{ width:38, height:38, borderRadius:10, background:`${item.color}15`,
                  border:`1px solid ${item.color}30`, display:"flex", alignItems:"center",
                  justifyContent:"center", fontSize:18, flexShrink:0 }}>{item.icon}</div>
                <div style={{ flex:1 }}>
                  <div style={s({ fontSize:13, fontWeight:700, color:C.text })}>{item.label}</div>
                  <div style={mono({ fontSize:11, color:C.muted })}>{item.desc}</div>
                </div>
                <span style={{ color:C.muted, fontSize:14 }}>→</span>
              </button>
            ))}
          </div>
        </Card>
      )}

      {/* General Settings */}
      <Card>
        <div style={s({ fontSize:15, fontWeight:800, color:C.text, marginBottom:16 })}>⚙️ General Settings</div>

        <div style={{ marginBottom:16 }}>
          <div style={mono({ fontSize:10, color:C.muted, marginBottom:8, letterSpacing:"0.08em" })}>APP LANGUAGE</div>
          <div style={{ display:"flex", gap:8 }}>
            {["English","Hindi","Telugu","Tamil"].map(l=>(
              <button key={l} onClick={()=>setLang(l)}
                style={s({ background: lang===l ? `${C.primary}15` : C.surface,
                  border:`1px solid ${lang===l ? C.primary+"50" : C.border}`,
                  color: lang===l ? C.primary : C.muted,
                  borderRadius:8, padding:"6px 14px", fontSize:12, fontWeight: lang===l?700:400 })}>
                {l}
              </button>
            ))}
          </div>
        </div>

        <Toggle value={notifs}     onChange={setNotifs}     label="Notifications"    desc="Email and in-app alerts for pipeline updates"/>
        <Toggle value={biasAlerts} onChange={setBiasAlerts} label="Bias Alerts"      desc="Real-time warnings when bias is detected"/>
        <Toggle value={darkMode}   onChange={setDarkMode}   label="Dark Mode"        desc="Currently active — light mode coming soon"/>
        <Toggle value={soundEnabled} onChange={setSoundEnabled} label="Key Sounds" desc="Typing clicks and notification chimes"/>

        {/* Volume Slider (pygame-style) */}
        {soundEnabled && (
          <div style={{ padding:"16px 0 4px" }}>
            <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:10 }}>
              <div>
                <div style={s({ fontSize:13, fontWeight:600, color:C.text })}>🔊 Key Sound Volume</div>
                <div style={mono({ fontSize:11, color:C.muted, marginTop:2 })}>Controls typing & notification volume</div>
              </div>
              <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                <div style={mono({ fontSize:13, fontWeight:700, color:C.primary })}>{Math.round(soundVolume*100)}%</div>
                <button onClick={()=>{ setSoundVolume(SoundSystem.volume); SoundSystem.playTap(); }}
                  style={s({ background:`${C.primary}15`, border:`1px solid ${C.primary}30`, color:C.primary,
                    borderRadius:6, padding:"4px 10px", fontSize:11, fontWeight:700 })}>
                  Test 🔔
                </button>
              </div>
            </div>
            <div style={{ position:"relative", height:24, display:"flex", alignItems:"center" }}>
              <div style={{ position:"absolute", left:0, right:0, height:6, background:C.border, borderRadius:3 }}>
                <div style={{ height:"100%", width:`${soundVolume*100}%`, background:C.primary, borderRadius:3, transition:"width 0.1s" }}/>
              </div>
              <input type="range" min="0" max="1" step="0.01" value={soundVolume}
                onChange={e=>{ const v=parseFloat(e.target.value); setSoundVolume(v); SoundSystem.volume=v; SoundSystem.playTap(); }}
                style={{ position:"absolute", left:0, right:0, width:"100%", opacity:0, cursor:"pointer", height:24, zIndex:2 }}/>
              <div style={{ position:"absolute", left:`calc(${soundVolume*100}% - 9px)`,
                width:18, height:18, borderRadius:"50%", background:C.primary,
                border:`2px solid #fff`, boxShadow:`0 0 8px ${C.primary}60`, pointerEvents:"none", transition:"left 0.05s" }}/>
            </div>
            <div style={{ display:"flex", justifyContent:"space-between", marginTop:4 }}>
              <span style={mono({ fontSize:10, color:C.muted })}>0%</span>
              <span style={mono({ fontSize:10, color:C.muted })}>50%</span>
              <span style={mono({ fontSize:10, color:C.muted })}>100%</span>
            </div>
          </div>
        )}

        <button onClick={save}
          style={s({ background: saved ? C.green : C.primary, color:"#000", border:"none",
            borderRadius:10, padding:"10px 28px", fontSize:13, fontWeight:700, marginTop:20,
            transition:"background 0.3s" })}>
          {saved ? "✅ Saved!" : "Save Changes"}
        </button>
      </Card>

      {/* Notification Preferences */}
      <Card>
        <div style={s({ fontSize:15, fontWeight:800, color:C.text, marginBottom:16 })}>🔔 Notification Preferences</div>
        {[
          { label:"New candidate applications",   enabled:true  },
          { label:"Bias flag raised",             enabled:true  },
          { label:"Interview completed",          enabled:true  },
          { label:"Shortlist updated",            enabled:false },
          { label:"Weekly diversity report",      enabled:user.role!=="Employee" },
          { label:"System updates",               enabled:user.role==="Admin" },
        ].map((n,i)=>(
          <div key={i} style={{ display:"flex", justifyContent:"space-between", alignItems:"center",
            padding:"9px 0", borderBottom:`1px solid ${C.border}20` }}>
            <span style={mono({ fontSize:12, color:C.muted })}>{n.label}</span>
            <Badge color={n.enabled?C.green:C.red}>{n.enabled?"ON":"OFF"}</Badge>
          </div>
        ))}
      </Card>

      {/* Danger Zone */}
      <Card style={{ borderColor:`${C.red}25` }}>
        <div style={s({ fontSize:15, fontWeight:800, color:C.red, marginBottom:16 })}>⚠️ Account</div>
        <div style={{ display:"flex", gap:12, flexWrap:"wrap" }}>
          <button style={s({ background:`${C.amber}15`, border:`1px solid ${C.amber}30`,
            color:C.amber, borderRadius:10, padding:"10px 20px", fontSize:13, fontWeight:700 })}>
            🔒 Change Password
          </button>
          <button onClick={onLogout}
            style={s({ background:`${C.red}15`, border:`1px solid ${C.red}30`,
              color:C.red, borderRadius:10, padding:"10px 20px", fontSize:13, fontWeight:700 })}>
            🚪 Logout
          </button>
          {user.role === "Admin" && (
            <button style={s({ background:`${C.red}08`, border:`1px solid ${C.red}20`,
              color:`${C.red}90`, borderRadius:10, padding:"10px 20px", fontSize:13, fontWeight:700 })}>
              🗑️ Delete Account
            </button>
          )}
        </div>
      </Card>
    </div>
  );
}

/* ═══════════════════════════════════════════════
   MAIN APP
═══════════════════════════════════════════════ */
const ALL_NAV = [
  { id:"dashboard",      label:"Dashboard",       icon:"⬛" },
  { id:"jd-scanner",     label:"JD Scanner",      icon:"🔍" },
  { id:"resume",         label:"Resume AI",       icon:"📄" },
  { id:"tests",          label:"Skill Tests",     icon:"⚡" },
  { id:"candidates",     label:"Candidates",      icon:"👥" },
  { id:"diversity",      label:"Diversity Hub",   icon:"📊" },
  { id:"insights",       label:"Company Intel",   icon:"🏢" },
  { id:"interview",      label:"AI Interview",    icon:"🎤" },
  { id:"live-interview", label:"Live Interview",  icon:"📹" },
  { id:"settings",       label:"Settings",        icon:"⚙️" },
];

export default function HireIQ() {
  const [user, setUser]   = useState(null);
  const [active, setActive] = useState("dashboard");

  const handleLogin  = (u) => { setUser(u); setActive("dashboard"); };
  const handleLogout = () => { setUser(null); setActive("dashboard"); };

  if (!user) return (
    <>
      <style>{FONT}</style>
      <LoginView onLogin={handleLogin}/>
    </>
  );

  const rc = ROLE_CONFIG[user.role];
  const NAV = ALL_NAV.filter(n => rc.navIds.includes(n.id));

  const VIEWS = {
    "dashboard":      <DashboardView onNav={setActive}/>,
    "jd-scanner":     <JDScannerView/>,
    "resume":         <ResumeScreenerView/>,
    "tests":          <SkillTestsView/>,
    "candidates":     <CandidatesView/>,
    "diversity":      <DiversityView/>,
    "insights":       <CompanyInsightsView/>,
    "interview":      <AIInterviewView/>,
    "live-interview": <LiveInterviewView user={user}/>,
    "settings":       <SettingsView user={user} onLogout={handleLogout}/>,
  };

  // Guard: if current active isn't in role's nav, reset to dashboard
  const safeActive = rc.navIds.includes(active) ? active : "dashboard";

  return (
    <>
      <style>{FONT}</style>
      <div style={{ display:"flex", height:"100vh", background:C.bg, color:C.text, fontFamily:"'Syne',sans-serif", overflow:"hidden" }}>

        {/* ── SIDEBAR ── */}
        <div style={{ width:220, background:C.surface, borderRight:`1px solid ${C.border}`,
          display:"flex", flexDirection:"column", flexShrink:0 }}>
          {/* Logo */}
          <div style={{ padding:"1.25rem 1.25rem 0.75rem", borderBottom:`1px solid ${C.border}` }}>
            <div style={s({ fontSize:22, fontWeight:800, color:C.primary, letterSpacing:"-0.02em" })}>HireIQ</div>
            <div style={mono({ fontSize:10, color:C.muted, letterSpacing:"0.08em" })}>BIAS-AWARE HIRING</div>
          </div>

          {/* Role Badge */}
          <div style={{ padding:"10px 12px", margin:"8px 10px 0",
            background:`${rc.color}12`, border:`1px solid ${rc.color}25`, borderRadius:10 }}>
            <div style={{ display:"flex", alignItems:"center", gap:8 }}>
              <span style={{ fontSize:16 }}>{rc.icon}</span>
              <div>
                <div style={s({ fontSize:12, fontWeight:700, color:rc.color })}>{user.name}</div>
                <div style={mono({ fontSize:10, color:C.muted })}>{user.role} · {user.sector}</div>
              </div>
            </div>
          </div>

          {/* Nav */}
          <nav style={{ flex:1, padding:"0.75rem 0.75rem", display:"flex", flexDirection:"column", gap:2, overflowY:"auto" }}>
            {NAV.map(n=>(
              <button key={n.id} onClick={()=>setActive(n.id)}
                style={{ display:"flex", alignItems:"center", gap:10, padding:"9px 12px",
                  borderRadius:10, border:"none", cursor:"pointer", textAlign:"left", width:"100%",
                  background: safeActive===n.id ? C.pDim : "transparent",
                  color: safeActive===n.id ? C.primary : C.muted,
                  borderLeft: safeActive===n.id ? `3px solid ${C.primary}` : "3px solid transparent",
                  transition:"all 0.15s", fontFamily:"'Syne',sans-serif",
                  fontSize:13, fontWeight: safeActive===n.id ? 700 : 400 }}>
                <span style={{ fontSize:15 }}>{n.icon}</span>
                {n.label}
              </button>
            ))}
          </nav>

          {/* Bias Meter */}
          <div style={{ padding:"0.75rem 1rem", borderTop:`1px solid ${C.border}` }}>
            <div style={mono({ fontSize:10, color:C.muted, marginBottom:6 })}>SYSTEM BIAS SCORE</div>
            <div style={{ height:6, background:C.border, borderRadius:3, marginBottom:4 }}>
              <div style={{ height:"100%", width:"18%", background:C.green, borderRadius:3 }}/>
            </div>
            <div style={{ display:"flex", justifyContent:"space-between" }}>
              <span style={mono({ fontSize:10, color:C.green })}>18% — Low</span>
              <span style={mono({ fontSize:10, color:C.muted })}>✅ EEOC</span>
            </div>
          </div>
        </div>

        {/* ── MAIN CONTENT ── */}
        <div style={{ flex:1, display:"flex", flexDirection:"column", overflow:"hidden" }}>
          {/* Header */}
          <div style={{ padding:"0.875rem 1.5rem", borderBottom:`1px solid ${C.border}`,
            background:C.surface, display:"flex", justifyContent:"space-between", alignItems:"center", flexShrink:0 }}>
            <div>
              <div style={s({ fontSize:16, fontWeight:800, color:C.text })}>
                {ALL_NAV.find(n=>n.id===safeActive)?.icon} {ALL_NAV.find(n=>n.id===safeActive)?.label}
              </div>
              <div style={mono({ fontSize:11, color:C.muted })}>{new Date().toDateString()}</div>
            </div>
            <div style={{ display:"flex", gap:10, alignItems:"center" }}>
              <div style={{ padding:"4px 12px", borderRadius:8, background:`${C.amber}15`,
                border:`1px solid ${C.amber}30` }}>
                <span style={mono({ fontSize:11, color:C.amber })}>⚠ 3 Bias Alerts</span>
              </div>
              <button onClick={()=>setActive("settings")}
                style={{ width:34, height:34, borderRadius:"50%", background:`${rc.color}20`,
                  border:`2px solid ${rc.color}40`, display:"flex", alignItems:"center",
                  justifyContent:"center", fontSize:14, cursor:"pointer" }}
                title={`${user.name} (${user.role})`}>
                {rc.icon}
              </button>
            </div>
          </div>

          {/* Scrollable Content */}
          <div style={{ flex:1, overflow:"auto", padding:"1.5rem" }}>
            {VIEWS[safeActive]}
          </div>
        </div>
      </div>
    </>
  );
}
