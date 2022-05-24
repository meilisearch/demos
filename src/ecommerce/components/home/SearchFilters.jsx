import {
  ClearRefinements,
  RatingMenu,
  RefinementList,
} from 'react-instantsearch-dom';
import CustomRangeSlider from '../slider/Slider';
import styles from '../../styles/searchFilters.module.css';

const SearchFilters = () => (
  <div className={styles.products}>
    <h2 className={styles.resultPara}>
      <span>Filters</span>
      <ClearRefinements />
    </h2>
    <h4 style={{ marginTop: 0 }}>Categories</h4>
    <RefinementList attribute='category' />
    <h4>Tags</h4>
    <RefinementList attribute='tag' />
    <h4>Brands</h4>
    <RefinementList attribute='brand' showMore={true} />
    <h4>Price</h4>
    <CustomRangeSlider attribute='price' />
    <h4 style={{ marginTop: '5rem' }}>Rating</h4>
    <RatingMenu attribute='rating' max={5} />
  </div>
);

export default SearchFilters;
