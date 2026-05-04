import React, { Fragment } from "react";

export const Billing = () => (
  <Fragment>
    <h1 className="title">Billing</h1>
    <p>For billing assistance, <a href={process.env.discordInvite}>join our Discord</a>.</p>
  </Fragment>
);

export default Billing;