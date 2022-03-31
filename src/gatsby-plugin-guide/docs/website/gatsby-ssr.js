/* eslint-disable import/prefer-default-export, react/prop-types */
// see https://github.com/mui-org/material-ui/blob/master/examples/gatsby/plugins/gatsby-plugin-top-layout/gatsby-ssr.js
import React from 'react';
import Root from './src/layout/Root';

export const wrapRootElement = ({ element }) => {
  return <Root>{element}</Root>;
};
