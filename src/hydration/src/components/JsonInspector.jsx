import styles from './JsonInspector.module.css';

/* Syntax-highlight JSON with special treatment for hydrated arrays */
function tokenize(json, hydrated) {
  // We'll walk the string and emit spans
  const tokens = [];
  let i = 0;

  function peek() { return json[i]; }
  function consume() { return json[i++]; }

  function skipWhitespace() {
    const start = i;
    while (i < json.length && /\s/.test(json[i])) i++;
    if (i > start) tokens.push({ type: 'ws', text: json.slice(start, i) });
  }

  function readString() {
    let s = '"';
    i++; // opening quote
    while (i < json.length) {
      const ch = consume();
      s += ch;
      if (ch === '\\') s += consume();
      else if (ch === '"') break;
    }
    return s;
  }

  function readLiteral() {
    const start = i;
    while (i < json.length && /[0-9.\-+eEtruefalsn]/.test(json[i])) i++;
    return json.slice(start, i);
  }

  function parse() {
    skipWhitespace();
    if (i >= json.length) return;
    const ch = peek();

    if (ch === '{') {
      tokens.push({ type: 'brace', text: '{' }); i++;
      let first = true;
      skipWhitespace();
      while (i < json.length && peek() !== '}') {
        if (!first) {
          tokens.push({ type: 'comma', text: peek() === ',' ? ',' : '' });
          if (peek() === ',') i++;
        }
        first = false;
        skipWhitespace();
        // key
        const key = readString();
        const keyName = key.slice(1, -1);
        tokens.push({ type: 'key', text: key, keyName });
        skipWhitespace();
        tokens.push({ type: 'colon', text: ':' }); i++;
        skipWhitespace();

        // value — check if this key is actors/genres and value is array
        const isHydratedField = hydrated && keyName === 'actors';
        if (isHydratedField && peek() === '[') {
          tokens.push({ type: 'hydratedOpen', text: '[' }); i++;
          skipWhitespace();
          let fFirst = true;
          while (i < json.length && peek() !== ']') {
            if (!fFirst) {
              tokens.push({ type: 'hydratedComma', text: ',' }); i++;
            }
            fFirst = false;
            skipWhitespace();
            tokens.push({ type: 'hydratedStart', text: '' });
            parseValue();
            tokens.push({ type: 'hydratedEnd', text: '' });
            skipWhitespace();
          }
          tokens.push({ type: 'hydratedClose', text: ']' }); i++;
        } else {
          parseValue();
        }
        skipWhitespace();
      }
      tokens.push({ type: 'brace', text: '}' }); i++;
    } else if (ch === '[') {
      tokens.push({ type: 'bracket', text: '[' }); i++;
      let first = true;
      skipWhitespace();
      while (i < json.length && peek() !== ']') {
        if (!first) { tokens.push({ type: 'comma', text: ',' }); i++; }
        first = false;
        skipWhitespace();
        parseValue();
        skipWhitespace();
      }
      tokens.push({ type: 'bracket', text: ']' }); i++;
    } else if (ch === '"') {
      tokens.push({ type: 'string', text: readString() });
    } else {
      const lit = readLiteral();
      const type = lit === 'true' || lit === 'false' ? 'bool' : lit === 'null' ? 'null' : 'number';
      tokens.push({ type, text: lit });
    }
  }

  function parseValue() { parse(); }

  parse();
  return tokens;
}

function renderTokens(tokens) {
  const elements = [];
  let inHydrated = false;

  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i];
    switch (t.type) {
      case 'ws': elements.push(t.text); break;
      case 'brace': elements.push(<span key={i} className={styles.brace}>{t.text}</span>); break;
      case 'bracket': elements.push(<span key={i} className={styles.bracket}>{t.text}</span>); break;
      case 'key': elements.push(<span key={i} className={styles.key}>{t.text}</span>); break;
      case 'colon': elements.push(<span key={i} className={styles.colon}>{t.text}</span>); break;
      case 'comma': elements.push(<span key={i} className={styles.comma}>{t.text}</span>); break;
      case 'string': elements.push(<span key={i} className={styles.string}>{t.text}</span>); break;
      case 'number': elements.push(<span key={i} className={styles.number}>{t.text}</span>); break;
      case 'bool': elements.push(<span key={i} className={styles.bool}>{t.text}</span>); break;
      case 'null': elements.push(<span key={i} className={styles.null}>{t.text}</span>); break;
      case 'hydratedOpen': elements.push(<span key={i} className={styles.hydratedBracket}>{t.text}</span>); inHydrated = true; break;
      case 'hydratedClose': elements.push(<span key={i} className={styles.hydratedBracket}>{t.text}</span>); inHydrated = false; break;
      case 'hydratedComma': elements.push(<span key={i} className={styles.hydratedComma}>{t.text}</span>); break;
      case 'hydratedStart': break;
      case 'hydratedEnd': break;
      default: elements.push(t.text);
    }
  }
  return elements;
}

export default function JsonInspector({ movie, hydrated }) {
  const indexName = hydrated ? 'top_movies_hydrated' : 'top_movies';

  if (!movie) {
    return (
      <aside className={styles.panel}>
        <div className={styles.empty}>
          <p>Select a movie to inspect its document</p>
        </div>
      </aside>
    );
  }

  // Clean up _formatted before display
  const { _formatted, ...cleanMovie } = movie;
  const json = JSON.stringify(cleanMovie, null, 2);

  let rendered;
  try {
    const tokens = tokenize(json, hydrated);
    rendered = renderTokens(tokens);
  } catch {
    rendered = json;
  }

  return (
    <aside className={styles.panel}>
      <div className={styles.panelHeader}>
        <span className={styles.label}>Response from</span>
        <span className={styles.indexBadge}>{indexName}</span>
      </div>
      <pre className={styles.json}>
        <code>{rendered}</code>
      </pre>
    </aside>
  );
}
