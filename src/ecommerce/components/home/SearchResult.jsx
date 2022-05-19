import Link from "next/link";
import {
  Pagination,
  SortBy,
  connectStateResults,
} from "react-instantsearch-dom";
import SearchFilters from "./SearchFilters";
import styles from "../../styles/searchResult.module.css";

const getString = (str, length = 40, desc) => {
  const strng = str.replace(/[^\w\s]/gi, "");
  if (!strng) {
    const description = desc.replace(/[^\w\s]/gi, "");
    return `${description.substring(0, length)}${
      description.length > length ? "..." : ""
    }`;
  }
  return `${strng?.substring(0, length)}${strng.length > length ? "..." : ""}`;
};

const Hit = ({ product }) => {
  const reviewCount = parseInt(product?.reviews_count || 1);
  const { rating, images, title, description, brand, price } = product;

  return (
    <div className={styles.card}>
      <Link
        href={{
          pathname: `/product/${product.id}`,
        }}
        passHref
      >
        <a>
          <div
            className={styles.productResImg}
            style={{ backgroundImage: `url(${images[0]})` }}
          />
          <div className={styles.productResCntnt}>
            <h6 className={styles.productResBrand}>{brand}</h6>
            <div className={styles.productResTitl}>{title}</div>
            <div className={styles.productResDesc}>
              {getString(description, 40, title)}
            </div>
            <div className={styles.productResPrice}>${price}</div>
            <div className={styles.productResReview}>
              {reviewCount ? (
                <div className={styles.productRateWrap}>
                  <span className={styles.productRate}>
                    {reviewCount} review
                    {reviewCount === 1 ? "" : "s"}
                  </span>{" "}
                  <span>⭐ {rating}</span>
                </div>
              ) : (
                "No Review"
              )}
            </div>
          </div>
        </a>
      </Link>
    </div>
  );
};

const Results = connectStateResults(
  ({ searchState, searchResults, searching }) => {
    const hits = searchResults?.hits;

    if (!searchResults) {
      return "Loading";
    }

    return (
      <>
        <SearchFilters />
        <div className={styles.products}>
          {searchResults.nbHits !== 0 ? (
            <>
              <div className={styles.resultPara}>
                <span>
                  Showing {searchResults?.hits.length || 0} of{" "}
                  {searchResults?.nbHits || 0}{" "}
                  {searchState.query &&
                    !searching &&
                    `for "${searchState.query}"`}
                </span>
                <div style={{ display: "flex", gap: "1rem" }}>
                  <SortBy
                    defaultRefinement="products"
                    items={[
                      { value: "products", label: "Sort" },
                      {
                        value: "products:price:desc",
                        label: "Price: High to Low",
                      },
                      {
                        value: "products:price:asc",
                        label: "Price: Low to High",
                      },
                      {
                        value: "products:reviews_count:desc",
                        label: "Most Reviews",
                      },
                    ]}
                  />
                </div>
              </div>
              <div className={styles.grid}>
                {hits?.length > 0 &&
                  hits.map((product) => (
                    <Hit key={product.id} product={product} />
                  ))}
              </div>
            </>
          ) : (
            <p className={styles.paragraph}>
              No results have been found for {searchState.query}.
            </p>
          )}
          <Pagination showLast={true} />
        </div>
      </>
    );
  }
);

export default Results;
