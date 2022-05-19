import styles from "../styles/home.module.css";
import Results from "../components/home/SearchResult";

export default function Home() {
  return (
    <div className={styles.container}>
      <main className={styles.main}>
        <div className={styles.mainContent}>
          <Results />
        </div>
      </main>
    </div>
  );
}

export const getStaticProps = async () => {
  return {
    props: {},
  };
};
