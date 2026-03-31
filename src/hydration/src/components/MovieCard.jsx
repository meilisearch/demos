import styles from './MovieCard.module.css';

function StarRating({ score }) {
  const stars = Math.round((score / 10) * 5);
  return (
    <span className={styles.stars} title={`${score}/10`}>
      {Array.from({ length: 5 }, (_, i) => (
        <span key={i} className={i < stars ? styles.starFilled : styles.starEmpty}>
          {i < stars ? '★' : '☆'}
        </span>
      ))}
      <span className={styles.scoreText}>{score?.toFixed(1)}</span>
    </span>
  );
}

function initials(name) {
  return name
    .split(' ')
    .slice(0, 2)
    .map(w => w[0])
    .join('')
    .toUpperCase();
}

function ActorCard({ actor }) {
  const photoUrl = actor.profile_path
    ? `https://image.tmdb.org/t/p/w185${actor.profile_path}`
    : null;
  const birthYear = actor.birthday ? new Date(actor.birthday).getFullYear() : null;

  return (
    <div className={styles.actorCard}>
      <div className={styles.actorPhoto}>
        {photoUrl ? (
          <img src={photoUrl} alt={actor.name} loading="lazy" />
        ) : (
          <span className={styles.actorInitials}>{initials(actor.name)}</span>
        )}
      </div>
      <p className={styles.actorName}>
        {actor.name.includes(' ')
          ? <>{actor.name.slice(0, actor.name.indexOf(' '))}<br />{actor.name.slice(actor.name.indexOf(' ') + 1)}</>
          : actor.name}
      </p>
      {birthYear && <p className={styles.actorBirth}>Born {birthYear}</p>}
    </div>
  );
}

function Pill({ value, hydrated }) {
  const isObject = typeof value === 'object' && value !== null;
  const isHydrated = hydrated && isObject;
  const rawId = isObject ? value.id : value;
  return (
    <span className={`${styles.pill} ${isHydrated ? styles.pillHydrated : styles.pillRaw}`}>
      {isHydrated
        ? value.name
        : <><span className={styles.pillHash}>#</span>{String(rawId)}</>}
    </span>
  );
}

export default function MovieCard({ movie, hydrated, selected, onClick }) {
  const year = movie.release_date ? new Date(movie.release_date).getFullYear() : null;
  const posterUrl = movie.poster_path
    ? `https://image.tmdb.org/t/p/w200${movie.poster_path}`
    : null;

  const genres = movie.genres ?? [];
  const actors = movie.actors ?? [];

  const isActorHydrated = hydrated && actors.length > 0 && typeof actors[0] === 'object' && actors[0] !== null;

  return (
    <article
      className={`${styles.card} ${selected ? styles.selected : ''}`}
      onClick={onClick}
    >
      <div className={styles.poster}>
        {posterUrl ? (
          <img src={posterUrl} alt={movie.title} loading="lazy" />
        ) : (
          <div className={styles.posterFallback}>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
              <rect x="2" y="2" width="20" height="20" rx="3" />
              <path d="M7 8h10M7 12h6" strokeLinecap="round" />
            </svg>
          </div>
        )}
      </div>

      <div className={styles.info}>
        <div className={styles.titleRow}>
          <h2
            className={styles.movieTitle}
            dangerouslySetInnerHTML={{
              __html: movie._formatted?.title ?? movie.title
            }}
          />
          {year && <span className={styles.year}>{year}</span>}
          {genres.slice(0, 3).map((g, i) => (
            <span key={i} className={`${styles.pill} ${styles.pillHydrated}`}>{g}</span>
          ))}
        </div>

        {movie.vote_average != null && (
          <StarRating score={movie.vote_average} />
        )}

        {actors.length > 0 && (
          isActorHydrated ? (
            <div className={styles.actorRow}>
              {actors.map((a, i) => (
                <ActorCard key={i} actor={a} />
              ))}
            </div>
          ) : (
            <div className={styles.pills}>
              <span className={styles.pillLabel}>actors</span>
              {actors.map((a, i) => {
                const rawId = typeof a === 'object' && a !== null ? a.id : a;
                return (
                  <span key={i} className={`${styles.pill} ${styles.pillRaw}`}>
                    <span className={styles.pillHash}>#</span>{String(rawId)}
                  </span>
                );
              })}
            </div>
          )
        )}
      </div>
    </article>
  );
}
