function [varargout] = subsasgn(varargin)
%SUBSASGN Subscripted reference for a CLASSREGTREE object.
%   Subscript assignment is not allowed for a CLASSREGTREE object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/06/14 05:26:27 $

error('stats:gmdistribution:subsasgn:NotAllowed',...
      'Subscripted assignments are not allowed.')